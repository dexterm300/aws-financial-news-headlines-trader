import json
import boto3
import uuid
import time
import os
import requests
from datetime import datetime
from typing import List, Dict, Optional

dynamodb = boto3.resource('dynamodb')
ssm = boto3.client('ssm')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def get_api_key(param_name: str, env_var: str = None) -> str:
    """Get API key from SSM parameter or environment variable"""
    if env_var and os.environ.get(env_var):
        return os.environ[env_var]
    
    try:
        response = ssm.get_parameter(Name=param_name, WithDecryption=True)
        return response['Parameter']['Value']
    except ssm.exceptions.ParameterNotFound:
        return ''

# Free news API sources
NEWS_SOURCES = {
    'newsapi': {
        'url': 'https://newsapi.org/v2/top-headlines',
        'params': {
            'category': 'business',
            'language': 'en',
            'pageSize': 20
        },
        'api_key_env': 'NEWS_API_KEY'
    },
    'alphavantage': {
        'url': 'https://www.alphavantage.co/query',
        'params': {
            'function': 'NEWS_SENTIMENT',
            'topics': 'financial_markets,earnings,ipo,mergers_and_acquisitions',
            'limit': 20
        },
        'api_key_env': 'ALPHAVANTAGE_API_KEY'
    }
}


def fetch_newsapi_articles(api_key: str) -> List[Dict]:
    """Fetch articles from NewsAPI.org"""
    try:
        url = NEWS_SOURCES['newsapi']['url']
        params = NEWS_SOURCES['newsapi']['params'].copy()
        params['apiKey'] = api_key
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        articles = []
        
        for article in data.get('articles', []):
            if article.get('title') and article.get('description'):
                articles.append({
                    'title': article.get('title', ''),
                    'description': article.get('description', ''),
                    'content': article.get('content', article.get('description', '')),
                    'url': article.get('url', ''),
                    'source': article.get('source', {}).get('name', 'NewsAPI'),
                    'publishedAt': article.get('publishedAt', datetime.utcnow().isoformat())
                })
        
        return articles
    except Exception as e:
        print(f"Error fetching from NewsAPI: {str(e)}")
        return []


def fetch_alphavantage_articles(api_key: str) -> List[Dict]:
    """Fetch articles from Alpha Vantage"""
    try:
        url = NEWS_SOURCES['alphavantage']['url']
        params = NEWS_SOURCES['alphavantage']['params'].copy()
        params['apikey'] = api_key
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        articles = []
        
        feed = data.get('feed', [])
        for item in feed:
            articles.append({
                'title': item.get('title', ''),
                'description': item.get('summary', ''),
                'content': item.get('summary', ''),
                'url': item.get('url', ''),
                'source': item.get('source', 'AlphaVantage'),
                'publishedAt': item.get('time_published', datetime.utcnow().isoformat()),
                'tickers': item.get('ticker_sentiment', [])  # Already has ticker info
            })
        
        return articles
    except Exception as e:
        print(f"Error fetching from AlphaVantage: {str(e)}")
        return []


def fetch_finlight_articles() -> List[Dict]:
    """Fetch articles from Finlight (free tier, no API key needed for basic)"""
    try:
        # Using a free RSS feed or scraping approach
        # For now, using a mock structure - user can configure actual endpoint
        url = 'https://www.finlight.me/api/v1/news'
        
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            return data.get('articles', [])
        return []
    except Exception as e:
        print(f"Error fetching from Finlight: {str(e)}")
        return []


def save_article(article: Dict) -> Optional[str]:
    """Save article to DynamoDB if it doesn't exist"""
    try:
        # Generate article ID from title hash or URL
        article_id = str(uuid.uuid5(uuid.NAMESPACE_URL, article.get('url', article.get('title', str(uuid.uuid4())))))
        timestamp = int(time.time())
        
        # Check if article already exists
        try:
            existing = table.get_item(Key={'articleId': article_id})
            if 'Item' in existing:
                print(f"Article already exists: {article_id}")
                return None
        except Exception as e:
            # If get_item fails, log but continue (might be permissions issue)
            print(f"Warning: Could not check existing article: {str(e)}")
        
        # Save new article
        item = {
            'articleId': article_id,
            'title': article.get('title', 'No title'),
            'description': article.get('description', ''),
            'content': article.get('content', article.get('description', '')),
            'url': article.get('url', ''),
            'source': article.get('source', 'Unknown'),
            'publishedAt': article.get('publishedAt', datetime.utcnow().isoformat()),
            'timestamp': timestamp,
            'status': 'pending_analysis',
            'tickers': article.get('tickers', []),  # Pre-populated if available
            'sentiment': None,
            'analysis': None,
            'tradingStrategies': None
        }
        
        table.put_item(Item=item)
        title_preview = article.get('title', 'No title')[:50]
        print(f"Saved article: {article_id} - {title_preview}")
        return article_id
        
    except Exception as e:
        print(f"Error saving article: {str(e)}")
        return None


def handler(event, context):
    """Main Lambda handler"""
    articles_fetched = 0
    articles_saved = 0
    
    # Fetch from multiple sources
    news_api_key = get_api_key('/financial-news/news-api-key', 'NEWS_API_KEY')
    alphavantage_key = get_api_key('/financial-news/alphavantage-api-key', 'ALPHAVANTAGE_API_KEY')
    
    all_articles = []
    
    # Try NewsAPI
    if news_api_key:
        articles = fetch_newsapi_articles(news_api_key)
        all_articles.extend(articles)
        articles_fetched += len(articles)
    
    # Try Alpha Vantage
    if alphavantage_key:
        articles = fetch_alphavantage_articles(alphavantage_key)
        all_articles.extend(articles)
        articles_fetched += len(articles)
    
    # Try Finlight (if configured)
    try:
        articles = fetch_finlight_articles()
        all_articles.extend(articles)
        articles_fetched += len(articles)
    except Exception as e:
        print(f"Error fetching Finlight articles: {str(e)}")
        # Continue with other sources
    
    # Remove duplicates based on title similarity
    seen_titles = set()
    unique_articles = []
    for article in all_articles:
        title = article.get('title', '').strip()
        if title:
            title_lower = title.lower()
            if title_lower not in seen_titles:
                seen_titles.add(title_lower)
                unique_articles.append(article)
    
    # Save articles
    for article in unique_articles:
        article_id = save_article(article)
        if article_id:
            articles_saved += 1
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'News ingestion completed',
            'articles_fetched': articles_fetched,
            'articles_saved': articles_saved,
            'unique_articles': len(unique_articles)
        })
    }


import json
import boto3
import os
from typing import Dict, List
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
# Use environment variable for region or default to us-east-1
bedrock_region = os.environ.get('BEDROCK_REGION', 'us-east-1')
bedrock = boto3.client('bedrock-runtime', region_name=bedrock_region)
table = dynamodb.Table(os.environ['TABLE_NAME'])
connections_table_name = os.environ.get('CONNECTIONS_TABLE_NAME', 'WebSocketConnections')
connections_table = dynamodb.Table(connections_table_name)

def get_apigw_client():
    """Get API Gateway Management API client"""
    ws_endpoint = os.environ.get('WS_API_ENDPOINT', '')
    ws_api_id = os.environ.get('WS_API_ID', '')
    
    if ws_endpoint and ws_api_id:
        # Convert wss:// to https://
        endpoint_url = ws_endpoint.replace('wss://', 'https://').replace('ws://', 'http://')
        if not endpoint_url.endswith('/prod'):
            endpoint_url = f"{endpoint_url}/{ws_api_id}/prod"
        return boto3.client('apigatewaymanagementapi', endpoint_url=endpoint_url)
    return None

BEDROCK_MODEL_ID = 'anthropic.claude-3-sonnet-20240229-v1:0'  # Claude Sonnet 3.5


def generate_prompt(article: Dict) -> str:
    """Generate prompt for Bedrock analysis"""
    title = article.get('title', '')
    content = article.get('content', article.get('description', ''))
    
    prompt = f"""Analyze the following financial news article and provide:

1. Sentiment Analysis: Determine if the news is bullish, bearish, or neutral for the affected companies
2. Affected S&P 500 Tickers: Identify which S&P 500 companies are mentioned or affected (provide ticker symbols only, comma-separated)
3. For each affected ticker, provide:
   - Sentiment (bullish/bearish/neutral)
   - Brief reasoning

Article Title: {title}
Article Content: {content}

Respond ONLY with valid JSON in this exact format:
{{
  "sentiment_overall": "bullish|bearish|neutral",
  "affected_tickers": [
    {{
      "ticker": "AAPL",
      "sentiment": "bullish",
      "reasoning": "Brief explanation"
    }}
  ]
}}

Only include tickers that are actually in the S&P 500 and clearly mentioned or affected by the news. Be specific and accurate."""

    return prompt


def analyze_with_bedrock(article: Dict) -> Dict:
    """Analyze article using Amazon Bedrock"""
    try:
        prompt = generate_prompt(article)
        
        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 2000,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        })
        
        response = bedrock.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            body=body
        )
        
        response_body = json.loads(response['body'].read())
        content = response_body['content'][0]['text']
        
        # Parse JSON from response
        try:
            # Extract JSON from markdown code blocks if present
            if '```json' in content:
                content = content.split('```json')[1].split('```')[0].strip()
            elif '```' in content:
                content = content.split('```')[1].split('```')[0].strip()
            
            analysis = json.loads(content)
            return analysis
        except json.JSONDecodeError as e:
            print(f"Error parsing Bedrock response: {e}")
            print(f"Response content: {content}")
            return {
                "sentiment_overall": "neutral",
                "affected_tickers": []
            }
            
    except Exception as e:
        print(f"Error calling Bedrock: {str(e)}")
        return {
            "sentiment_overall": "neutral",
            "affected_tickers": []
        }


def generate_trading_strategies(ticker: str, sentiment: str) -> List[str]:
    """Generate options trading strategies based on sentiment"""
    sentiment_lower = sentiment.lower()
    strategies = []
    
    if sentiment_lower == 'bullish':
        strategies = [
            'long call',
            'short put',
            'short put credit spread',
            'long call debit spread',
            'bull call spread',
            'covered call (if holding stock)'
        ]
    elif sentiment_lower == 'bearish':
        strategies = [
            'long put',
            'short call',
            'short call credit spread',
            'long put debit spread',
            'bear put spread',
            'protective put (if holding stock)'
        ]
    else:  # neutral
        strategies = [
            'iron condor',
            'butterfly spread',
            'calendar spread',
            'straddle/strangle (if expecting volatility)'
        ]
    
    return strategies


def broadcast_to_websocket(message: Dict):
    """Broadcast message to all connected WebSocket clients"""
    try:
        apigw = get_apigw_client()
        if not apigw:
            print("WebSocket API Gateway not configured")
            return
        
        # Get all connections
        response = connections_table.scan()
        connections = response.get('Items', [])
        
        message_json = json.dumps(message)
        
        for connection in connections:
            connection_id = connection.get('connectionId')
            if not connection_id:
                continue
            try:
                apigw.post_to_connection(
                    ConnectionId=connection_id,
                    Data=message_json.encode('utf-8')
                )
            except apigw.exceptions.GoneException:
                # Connection closed, remove it
                connections_table.delete_item(Key={'connectionId': connection_id})
            except Exception as e:
                print(f"Error sending to connection {connection_id}: {str(e)}")
                
    except Exception as e:
        print(f"Error broadcasting to WebSocket: {str(e)}")


def process_article(article: Dict):
    """Process a single article"""
    article_id = article.get('articleId')
    if not article_id:
        raise ValueError("Article missing articleId")
    
    # Analyze with Bedrock
    print(f"Analyzing article: {article_id}")
    analysis = analyze_with_bedrock(article)
    
    # Generate trading strategies for each ticker
    trading_strategies = {}
    for ticker_info in analysis.get('affected_tickers', []):
        ticker = ticker_info.get('ticker')
        sentiment = ticker_info.get('sentiment', 'neutral')
        
        if not ticker:
            continue  # Skip invalid ticker entries
        
        strategies = generate_trading_strategies(ticker, sentiment)
        
        trading_strategies[ticker] = {
            'sentiment': sentiment,
            'reasoning': ticker_info.get('reasoning', ''),
            'strategies': strategies
        }
    
    # Update article in DynamoDB
    table.update_item(
        Key={'articleId': article_id},
        UpdateExpression='SET #status = :status, sentiment = :sentiment, analysis = :analysis, tradingStrategies = :strategies',
        ExpressionAttributeNames={
            '#status': 'status'
        },
        ExpressionAttributeValues={
            ':status': 'analyzed',
            ':sentiment': analysis.get('sentiment_overall', 'neutral'),
            ':analysis': json.dumps(analysis),
            ':strategies': json.dumps(trading_strategies)
        }
    )
    
    # Prepare message for frontend
    message = {
        'type': 'news_update',
        'articleId': article_id,
        'title': article.get('title', ''),
        'description': article.get('description', ''),
        'url': article.get('url', ''),
        'publishedAt': article.get('publishedAt', ''),
        'sentiment': analysis.get('sentiment_overall', 'neutral'),
        'affectedTickers': trading_strategies,
        'timestamp': datetime.utcnow().isoformat()
    }
    
    # Broadcast to WebSocket clients
    broadcast_to_websocket(message)
    
    return message


def convert_dynamodb_item(item_dict):
    """Convert DynamoDB format to regular Python dict"""
    if not item_dict:
        return {}
    
    result = {}
    for key, value in item_dict.items():
        if not isinstance(value, dict):
            result[key] = value
            continue
            
        if 'S' in value:  # String
            result[key] = value['S']
        elif 'N' in value:  # Number
            try:
                result[key] = int(value['N'])
            except ValueError:
                try:
                    result[key] = float(value['N'])
                except ValueError:
                    result[key] = value['N']  # Keep as string if can't convert
        elif 'BOOL' in value:  # Boolean
            result[key] = value['BOOL']
        elif 'NULL' in value:  # Null
            result[key] = None
        elif 'L' in value:  # List
            converted_list = []
            for item in value['L']:
                if isinstance(item, dict):
                    # Recursively convert nested items
                    converted_item = convert_dynamodb_item(item)
                    converted_list.append(converted_item)
                else:
                    converted_list.append(item)
            result[key] = converted_list
        elif 'M' in value:  # Map
            result[key] = convert_dynamodb_item(value['M'])
        elif 'SS' in value:  # String Set
            result[key] = list(value['SS'])
        elif 'NS' in value:  # Number Set
            result[key] = [int(n) if n.isdigit() else float(n) for n in value['NS']]
        else:
            result[key] = value
    return result


def handler(event, context):
    """Handler for DynamoDB stream events"""
    processed_count = 0
    error_count = 0
    
    try:
        for record in event.get('Records', []):
            if record.get('eventName') == 'INSERT':
                new_image = record.get('dynamodb', {}).get('NewImage', {})
                
                if not new_image:
                    continue
                
                # Convert DynamoDB format to regular dict
                try:
                    article = convert_dynamodb_item(new_image)
                except Exception as e:
                    print(f"Error converting DynamoDB item: {str(e)}")
                    error_count += 1
                    continue
                
                # Only process if status is pending_analysis
                if article.get('status') == 'pending_analysis':
                    try:
                        process_article(article)
                        processed_count += 1
                    except Exception as e:
                        error_count += 1
                        print(f"Error processing article {article.get('articleId', 'unknown')}: {str(e)}")
    
    except Exception as e:
        print(f"Error in handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': f'Handler error: {str(e)}'
            })
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Processed {processed_count} articles',
            'processed': processed_count,
            'errors': error_count
        })
    }


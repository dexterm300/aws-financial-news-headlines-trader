import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])


def handler(event, context):
    """Handle REST API requests for news"""
    path_parameters = event.get('pathParameters') or {}
    article_id = path_parameters.get('articleId')
    
    try:
        if article_id:
            # Get single article
            response = table.get_item(Key={'articleId': article_id})
            
            if 'Item' not in response:
                return {
                    'statusCode': 404,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({'error': 'Article not found'})
                }
            
            item = response['Item']
            article = {
                'articleId': item.get('articleId'),
                'title': item.get('title'),
                'description': item.get('description', ''),
                'content': item.get('content', ''),
                'url': item.get('url', ''),
                'source': item.get('source', ''),
                'publishedAt': item.get('publishedAt', ''),
                'sentiment': item.get('sentiment', 'neutral'),
                'affectedTickers': json.loads(item.get('tradingStrategies', '{}')) if item.get('tradingStrategies') and isinstance(item.get('tradingStrategies'), str) else (item.get('tradingStrategies') or {}),
                'analysis': json.loads(item.get('analysis', '{}')) if item.get('analysis') and isinstance(item.get('analysis'), str) else (item.get('analysis') or {})
            }
            
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(article)
            }
        else:
            # Get all articles (latest first)
            query_params = event.get('queryStringParameters') or {}
            limit = int(query_params.get('limit', 50))
            status = query_params.get('status', 'analyzed')
            
            if status == 'all':
                response = table.scan(Limit=limit)
            else:
                response = table.scan(
                    FilterExpression='#status = :status',
                    ExpressionAttributeNames={'#status': 'status'},
                    ExpressionAttributeValues={':status': status},
                    Limit=limit
                )
            
            articles = []
            for item in response.get('Items', []):
                articles.append({
                    'articleId': item.get('articleId'),
                    'title': item.get('title'),
                    'description': item.get('description', ''),
                    'url': item.get('url', ''),
                    'source': item.get('source', ''),
                    'publishedAt': item.get('publishedAt', ''),
                    'sentiment': item.get('sentiment', 'neutral'),
                    'affectedTickers': json.loads(item.get('tradingStrategies', '{}')) if item.get('tradingStrategies') and isinstance(item.get('tradingStrategies'), str) else (item.get('tradingStrategies') or {}),
                    'timestamp': item.get('timestamp', 0)
                })
            
            # Sort by timestamp descending
            articles.sort(key=lambda x: x.get('timestamp', 0), reverse=True)
            
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'articles': articles,
                    'count': len(articles)
                })
            }
            
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }


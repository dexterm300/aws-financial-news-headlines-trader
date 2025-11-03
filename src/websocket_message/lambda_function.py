import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def get_apigw_client(event):
    """Get API Gateway Management API client from event"""
    try:
        request_context = event.get('requestContext', {})
        domain = request_context.get('domainName')
        stage = request_context.get('stage')
        
        if not domain or not stage:
            raise ValueError("Missing domainName or stage in requestContext")
        
        endpoint_url = f"https://{domain}/{stage}"
        return boto3.client('apigatewaymanagementapi', endpoint_url=endpoint_url)
    except Exception as e:
        print(f"Error creating API Gateway client: {str(e)}")
        raise


def handler(event, context):
    """Handle WebSocket messages"""
    try:
        connection_id = event.get('requestContext', {}).get('connectionId')
        if not connection_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing connection ID'})
            }
        
        apigw = get_apigw_client(event)
        
        body = json.loads(event.get('body', '{}'))
        action = body.get('action', '')
        
        if action == 'get_latest':
            # Get latest news articles
            try:
                response = table.scan(
                    FilterExpression='#status = :status',
                    ExpressionAttributeNames={'#status': 'status'},
                    ExpressionAttributeValues={':status': 'analyzed'},
                    Limit=50
                )
                
                articles = []
                for item in response.get('Items', []):
                    try:
                        trading_strategies = item.get('tradingStrategies', '{}')
                        if trading_strategies:
                            trading_strategies = json.loads(trading_strategies) if isinstance(trading_strategies, str) else trading_strategies
                        else:
                            trading_strategies = {}
                    except json.JSONDecodeError:
                        trading_strategies = {}
                    
                    articles.append({
                        'articleId': item.get('articleId'),
                        'title': item.get('title', ''),
                        'description': item.get('description', ''),
                        'url': item.get('url', ''),
                        'publishedAt': item.get('publishedAt', ''),
                        'sentiment': item.get('sentiment', 'neutral'),
                        'affectedTickers': trading_strategies,
                        'timestamp': item.get('timestamp', 0)
                    })
                
                # Sort by timestamp descending
                articles.sort(key=lambda x: x.get('timestamp', 0), reverse=True)
                
                # Send response
                apigw.post_to_connection(
                    ConnectionId=connection_id,
                    Data=json.dumps({
                        'type': 'latest_news',
                        'articles': articles
                    }).encode('utf-8')
                )
            except Exception as e:
                print(f"Error fetching articles: {str(e)}")
                apigw.post_to_connection(
                    ConnectionId=connection_id,
                    Data=json.dumps({
                        'type': 'error',
                        'message': 'Failed to fetch articles'
                    }).encode('utf-8')
                )
        else:
            # Echo or handle other actions
            apigw.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({
                    'type': 'echo',
                    'message': f'Unknown action: {action}'
                }).encode('utf-8')
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Message processed'})
        }
    except Exception as e:
        print(f"Error processing message: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Message processing failed', 'error': str(e)})
        }


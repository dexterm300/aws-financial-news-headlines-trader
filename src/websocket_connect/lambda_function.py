import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
connections_table_name = os.environ.get('CONNECTIONS_TABLE_NAME', 'WebSocketConnections')
connections_table = dynamodb.Table(connections_table_name)


def handler(event, context):
    """Handle WebSocket connection"""
    try:
        connection_id = event.get('requestContext', {}).get('connectionId')
        if not connection_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing connection ID'})
            }
        
        # Store connection ID
        connections_table.put_item(
            Item={
                'connectionId': connection_id,
                'connectedAt': context.request_id if hasattr(context, 'request_id') else '',
                'ttl': int(context.aws_request_id[:10]) + 86400 if hasattr(context, 'aws_request_id') else 0  # 24 hour TTL
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Connected'})
        }
    except Exception as e:
        print(f"Error connecting: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Connection failed', 'error': str(e)})
        }


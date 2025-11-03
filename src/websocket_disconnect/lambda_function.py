import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
connections_table_name = os.environ.get('CONNECTIONS_TABLE_NAME', 'WebSocketConnections')
connections_table = dynamodb.Table(connections_table_name)


def handler(event, context):
    """Handle WebSocket disconnection"""
    try:
        connection_id = event.get('requestContext', {}).get('connectionId')
        if not connection_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing connection ID'})
            }
        
        # Remove connection
        connections_table.delete_item(
            Key={'connectionId': connection_id}
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Disconnected'})
        }
    except Exception as e:
        print(f"Error disconnecting: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Disconnection failed', 'error': str(e)})
        }


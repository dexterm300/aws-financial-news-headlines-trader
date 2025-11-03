output "websocket_api_endpoint" {
  description = "WebSocket API endpoint"
  value       = "wss://${aws_apigatewayv2_api.websocket.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.websocket.name}"
}

output "rest_api_endpoint" {
  description = "REST API endpoint"
  value       = "https://${aws_apigatewayv2_api.rest.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.rest.name}"
}

output "news_table_name" {
  description = "DynamoDB table name for news articles"
  value       = aws_dynamodb_table.news_articles.name
}

output "connections_table_name" {
  description = "DynamoDB table name for WebSocket connections"
  value       = aws_dynamodb_table.websocket_connections.name
}

output "news_ingestion_function_name" {
  description = "Name of the news ingestion Lambda function"
  value       = aws_lambda_function.news_ingestion.function_name
}

output "bedrock_analysis_function_name" {
  description = "Name of the Bedrock analysis Lambda function"
  value       = aws_lambda_function.bedrock_analysis.function_name
}


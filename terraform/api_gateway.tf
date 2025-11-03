# WebSocket API Gateway
resource "aws_apigatewayv2_api" "websocket" {
  name                       = "${var.project_name}-websocket"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

# WebSocket API Stage
resource "aws_apigatewayv2_stage" "websocket" {
  api_id      = aws_apigatewayv2_api.websocket.id
  name        = "prod"
  auto_deploy = true
}

# WebSocket Connect Route
resource "aws_apigatewayv2_integration" "websocket_connect" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"
  integration_uri   = aws_lambda_function.websocket_connect.invoke_arn
}

resource "aws_apigatewayv2_route" "websocket_connect" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_connect.id}"
}

# WebSocket Disconnect Route
resource "aws_apigatewayv2_integration" "websocket_disconnect" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"
  integration_uri   = aws_lambda_function.websocket_disconnect.invoke_arn
}

resource "aws_apigatewayv2_route" "websocket_disconnect" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_disconnect.id}"
}

# WebSocket Default Route (for messages)
resource "aws_apigatewayv2_integration" "websocket_message" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"
  integration_uri   = aws_lambda_function.websocket_message.invoke_arn
}

resource "aws_apigatewayv2_route" "websocket_message" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_message.id}"
}

# Lambda permissions for WebSocket API
resource "aws_lambda_permission" "websocket_connect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket.execution_arn}/*/$connect"
}

resource "aws_lambda_permission" "websocket_disconnect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket.execution_arn}/*/$disconnect"
}

resource "aws_lambda_permission" "websocket_message" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket.execution_arn}/*/$default"
}

# REST API Gateway for Get News
resource "aws_apigatewayv2_api" "rest" {
  name          = "${var.project_name}-rest"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

# REST API Stage
resource "aws_apigatewayv2_stage" "rest" {
  api_id      = aws_apigatewayv2_api.rest.id
  name        = "prod"
  auto_deploy = true
}

# REST API Routes
resource "aws_apigatewayv2_route" "get_news" {
  api_id    = aws_apigatewayv2_api.rest.id
  route_key = "GET /news"
  target    = "integrations/${aws_apigatewayv2_integration.get_news.id}"
}

resource "aws_apigatewayv2_route" "get_news_by_id" {
  api_id    = aws_apigatewayv2_api.rest.id
  route_key = "GET /news/{articleId}"
  target    = "integrations/${aws_apigatewayv2_integration.get_news.id}"
}

resource "aws_apigatewayv2_integration" "get_news" {
  api_id           = aws_apigatewayv2_api.rest.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_news.invoke_arn
}

# Lambda permission for REST API
resource "aws_lambda_permission" "get_news" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_news.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.rest.execution_arn}/*/*"
}


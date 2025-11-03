# Lambda: News Ingestion
resource "aws_lambda_function" "news_ingestion" {
  filename         = data.archive_file.news_ingestion.output_path
  function_name    = "${var.project_name}-ingestion"
  role            = aws_iam_role.news_ingestion.arn
  handler         = "lambda_function.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  source_code_hash = data.archive_file.news_ingestion.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.news_articles.name
    }
  }

  tags = {
    Name = "${var.project_name}-ingestion"
  }
}

# CloudWatch Event Rule for scheduled news ingestion
resource "aws_cloudwatch_event_rule" "news_ingestion_schedule" {
  name                = "${var.project_name}-ingestion-schedule"
  description         = "Trigger news ingestion every 5 minutes"
  schedule_expression = var.news_ingestion_schedule
}

resource "aws_cloudwatch_event_target" "news_ingestion" {
  rule      = aws_cloudwatch_event_rule.news_ingestion_schedule.name
  target_id = "NewsIngestionTarget"
  arn       = aws_lambda_function.news_ingestion.arn
}

resource "aws_lambda_permission" "news_ingestion_schedule" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_ingestion.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.news_ingestion_schedule.arn
}

# Lambda: Bedrock Analysis
resource "aws_lambda_function" "bedrock_analysis" {
  filename         = data.archive_file.bedrock_analysis.output_path
  function_name    = "${var.project_name}-bedrock-analysis"
  role            = aws_iam_role.bedrock_analysis.arn
  handler         = "lambda_function.handler"
  runtime         = var.lambda_runtime
  timeout         = var.bedrock_analysis_timeout
  memory_size     = var.bedrock_analysis_memory

  source_code_hash = data.archive_file.bedrock_analysis.output_base64sha256

  environment {
    variables = {
      TABLE_NAME             = aws_dynamodb_table.news_articles.name
      CONNECTIONS_TABLE_NAME = aws_dynamodb_table.websocket_connections.name
      WS_API_ENDPOINT        = "wss://${aws_apigatewayv2_api.websocket.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.websocket.name}"
      WS_API_ID              = aws_apigatewayv2_api.websocket.id
      BEDROCK_REGION         = var.aws_region
    }
  }

  tags = {
    Name = "${var.project_name}-bedrock-analysis"
  }
}

# DynamoDB Stream Event Source Mapping for Bedrock Analysis
resource "aws_lambda_event_source_mapping" "bedrock_analysis_stream" {
  event_source_arn  = aws_dynamodb_table.news_articles.stream_arn
  function_name     = aws_lambda_function.bedrock_analysis.arn
  starting_position = "LATEST"
  batch_size        = 5
  maximum_batching_window_in_seconds = 10
}

# Lambda: WebSocket Connect
resource "aws_lambda_function" "websocket_connect" {
  filename         = data.archive_file.websocket_connect.output_path
  function_name    = "${var.project_name}-websocket-connect"
  role            = aws_iam_role.websocket_connect.arn
  handler         = "lambda_function.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  source_code_hash = data.archive_file.websocket_connect.output_base64sha256

  environment {
    variables = {
      CONNECTIONS_TABLE_NAME = aws_dynamodb_table.websocket_connections.name
    }
  }

  tags = {
    Name = "${var.project_name}-websocket-connect"
  }
}

# Lambda: WebSocket Disconnect
resource "aws_lambda_function" "websocket_disconnect" {
  filename         = data.archive_file.websocket_disconnect.output_path
  function_name    = "${var.project_name}-websocket-disconnect"
  role            = aws_iam_role.websocket_disconnect.arn
  handler         = "lambda_function.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  source_code_hash = data.archive_file.websocket_disconnect.output_base64sha256

  environment {
    variables = {
      CONNECTIONS_TABLE_NAME = aws_dynamodb_table.websocket_connections.name
    }
  }

  tags = {
    Name = "${var.project_name}-websocket-disconnect"
  }
}

# Lambda: WebSocket Message
resource "aws_lambda_function" "websocket_message" {
  filename         = data.archive_file.websocket_message.output_path
  function_name    = "${var.project_name}-websocket-message"
  role            = aws_iam_role.websocket_message.arn
  handler         = "lambda_function.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  source_code_hash = data.archive_file.websocket_message.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.news_articles.name
    }
  }

  tags = {
    Name = "${var.project_name}-websocket-message"
  }
}

# Lambda: Get News (REST API)
resource "aws_lambda_function" "get_news" {
  filename         = data.archive_file.get_news.output_path
  function_name    = "${var.project_name}-get-news"
  role            = aws_iam_role.get_news.arn
  handler         = "lambda_function.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  source_code_hash = data.archive_file.get_news.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.news_articles.name
    }
  }

  tags = {
    Name = "${var.project_name}-get-news"
  }
}


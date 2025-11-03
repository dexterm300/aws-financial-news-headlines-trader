# DynamoDB Table for storing news articles
resource "aws_dynamodb_table" "news_articles" {
  name           = "${var.project_name}-articles"
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "articleId"

  attribute {
    name = "articleId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name     = "TimestampIndex"
    hash_key = "timestamp"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Name = "${var.project_name}-articles"
  }
}

# DynamoDB Table for WebSocket connections
resource "aws_dynamodb_table" "websocket_connections" {
  name         = "${var.project_name}-connections"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-websocket-connections"
  }
}


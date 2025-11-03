# Archive Lambda function code
data "archive_file" "news_ingestion" {
  type        = "zip"
  source_dir  = "${path.module}/../src/news_ingestion"
  output_path = "${path.module}/../lambda_packages/news_ingestion.zip"
}

data "archive_file" "bedrock_analysis" {
  type        = "zip"
  source_dir  = "${path.module}/../src/bedrock_analysis"
  output_path = "${path.module}/../lambda_packages/bedrock_analysis.zip"
}

data "archive_file" "websocket_connect" {
  type        = "zip"
  source_dir  = "${path.module}/../src/websocket_connect"
  output_path = "${path.module}/../lambda_packages/websocket_connect.zip"
}

data "archive_file" "websocket_disconnect" {
  type        = "zip"
  source_dir  = "${path.module}/../src/websocket_disconnect"
  output_path = "${path.module}/../lambda_packages/websocket_disconnect.zip"
}

data "archive_file" "websocket_message" {
  type        = "zip"
  source_dir  = "${path.module}/../src/websocket_message"
  output_path = "${path.module}/../lambda_packages/websocket_message.zip"
}

data "archive_file" "get_news" {
  type        = "zip"
  source_dir  = "${path.module}/../src/get_news"
  output_path = "${path.module}/../lambda_packages/get_news.zip"
}


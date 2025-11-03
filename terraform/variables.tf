variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "financial-news"
}

variable "news_ingestion_schedule" {
  description = "CloudWatch Events schedule expression for news ingestion"
  type        = string
  default     = "rate(5 minutes)"
}

variable "bedrock_model_id" {
  description = "Amazon Bedrock model ID to use"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "lambda_runtime" {
  description = "Python runtime version for Lambda functions"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Default timeout for Lambda functions (seconds)"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Default memory size for Lambda functions (MB)"
  type        = number
  default     = 512
}

variable "bedrock_analysis_timeout" {
  description = "Timeout for Bedrock analysis Lambda (seconds)"
  type        = number
  default     = 900
}

variable "bedrock_analysis_memory" {
  description = "Memory size for Bedrock analysis Lambda (MB)"
  type        = number
  default     = 2048
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}


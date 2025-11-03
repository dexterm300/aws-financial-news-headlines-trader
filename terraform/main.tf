terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    # Configure this with your S3 bucket for state
    # bucket = "your-terraform-state-bucket"
    # key    = "financial-news-analysis/terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "FinancialNewsAnalysis"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# Data source to get current AWS region and account
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


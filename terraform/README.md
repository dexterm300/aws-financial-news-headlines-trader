# Terraform Configuration for Financial News Analysis System

This directory contains Terraform configurations to deploy the Financial News Analysis System to AWS.

## Prerequisites

1. **Python 3.11+** (REQUIRED - must be in PATH)
   
   This project requires Python 3.11 or higher. Follow installation steps below:

   **Windows:**
   ```powershell
   # Download from https://www.python.org/downloads/
   # IMPORTANT: Check "Add Python to PATH" during installation
   
   # Verify installation:
   python --version
   python -m pip --version
   
   # If not found, add to PATH manually:
   # 1. Search "Environment Variables" in Windows
   # 2. Edit "Path" → Add Python installation directory
   # 3. Restart terminal
   ```

   **macOS:**
   ```bash
   # Install using Homebrew
   brew install python@3.11
   
   # Verify
   python3.11 --version
   python3.11 -m pip --version
   
   # Or download from https://www.python.org/downloads/macos/
   ```

   **Linux:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install python3.11 python3.11-venv python3.11-pip
   
   # Verify
   python3.11 --version
   python3.11 -m pip --version
   ```

   **Verify PATH Configuration:**
   ```bash
   # Windows
   python --version
   
   # macOS/Linux
   python3 --version
   # or explicitly
   python3.11 --version
   
   # If command not found, Python is not in PATH
   # See main README.md for detailed PATH setup
   ```

2. **Terraform** (>= 1.5.0)
   ```bash
   # Install Terraform
   # Windows: choco install terraform
   # macOS: brew install terraform
   # Linux: https://www.terraform.io/downloads
   ```

3. **AWS CLI** configured with appropriate credentials

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Install Python Dependencies

**IMPORTANT**: Ensure Python 3.11 is in PATH before proceeding.

Verify Python first:
```bash
# Windows
python --version

# macOS/Linux
python3 --version
```

Before packaging Lambda functions, install dependencies:

```bash
# Create virtual environments and install dependencies for each Lambda
cd ../src/news_ingestion

# Windows
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
deactivate

# macOS/Linux
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# Repeat for other Lambda functions:
# - bedrock_analysis
# - websocket_connect
# - websocket_disconnect
# - websocket_message
# - get_news
```

Or use the helper script (automatically uses correct Python):
```bash
# Windows
.\scripts\install_lambda_deps.ps1

# Linux/macOS
./scripts/install_lambda_deps.sh
```

### 3. Review and Customize Variables

Edit `terraform.tfvars` (create if doesn't exist):

```hcl
aws_region = "us-east-1"
environment = "prod"
project_name = "financial-news"
news_ingestion_schedule = "rate(5 minutes)"
```

### 4. Plan and Apply

```bash
# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

### 5. Get Outputs

After deployment, get your API endpoints:

```bash
terraform output websocket_api_endpoint
terraform output rest_api_endpoint
```

## Configuration

### Variables

Key variables in `variables.tf`:

- `aws_region`: AWS region (default: us-east-1)
- `environment`: Environment name (default: prod)
- `project_name`: Project prefix for resources
- `news_ingestion_schedule`: CloudWatch schedule (default: rate(5 minutes))
- `bedrock_model_id`: Bedrock model to use
- `lambda_runtime`: Python runtime version (default: python3.11)

### Backend Configuration

Configure remote state in `main.tf`:

```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "financial-news-analysis/terraform.tfstate"
  region = "us-east-1"
}
```

### Lambda Function Packaging

Terraform uses `archive_file` data source to zip Lambda functions. The packages are created in `../lambda_packages/` directory.

**Note**: Ensure Python dependencies are installed in each Lambda source directory before running `terraform apply`.

## Structure

```
terraform/
├── main.tf              # Provider and data sources
├── variables.tf        # Input variables
├── outputs.tf          # Output values
├── dynamodb.tf        # DynamoDB tables
├── lambda.tf          # Lambda functions
├── iam.tf             # IAM roles and policies
├── api_gateway.tf     # API Gateway (WebSocket + REST)
└── README.md          # This file
```

## Deployment Workflow

1. **Development**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. **Update Lambda code**:
   ```bash
   # Make changes to Lambda functions in src/
   terraform apply  # Terraform will detect changes and redeploy
   ```

3. **Update infrastructure**:
   ```bash
   # Edit .tf files
   terraform plan
   terraform apply
   ```

## Destroying Resources

To remove all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including DynamoDB tables and their data!

## Troubleshooting

### Lambda Package Errors

If you see errors about missing dependencies:
1. Ensure dependencies are installed in each Lambda source directory
2. The `archive_file` data source includes the entire source directory
3. For production, consider using Lambda layers for shared dependencies

### API Gateway Integration Errors

- Ensure Lambda permissions are correct
- Check API Gateway execution logs
- Verify route configurations match Lambda handlers

### DynamoDB Stream Errors

- Verify stream is enabled on the table
- Check Lambda event source mapping status
- Review CloudWatch logs for errors

## Cost Optimization

1. **Use variables** to adjust Lambda memory/timeout
2. **DynamoDB on-demand billing** is used by default
3. **Monitor CloudWatch** for Lambda execution costs
4. **Review Bedrock** token usage and costs

## State Management

For production, use remote state:

```bash
# Create S3 bucket for state (one-time)
aws s3 mb s3://your-terraform-state-bucket

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

Then uncomment and configure the backend block in `main.tf`.

## Migration from SAM/CloudFormation

If migrating from the SAM template:

1. Export existing resource names/IDs
2. Use `terraform import` for existing resources (if needed)
3. Or deploy fresh and migrate data manually

## Support

See main `README.md` for architecture details and troubleshooting.


# Terraform Deployment Guide

This guide walks you through deploying the Financial News Analysis System using Terraform.

## Prerequisites

1. **Install Python 3.11+**
   
   **Windows:**
   ```powershell
   # Verify Python is installed
   python --version
   # Should show: Python 3.11.x or higher
   
   # If not installed:
   # 1. Download from https://www.python.org/downloads/
   # 2. IMPORTANT: Check "Add Python to PATH" during installation
   # 3. Verify: python -m pip --version
   ```

   **macOS:**
   ```bash
   # Verify Python 3.11
   python3 --version
   
   # If not installed or wrong version:
   brew install python@3.11
   
   # Verify PATH
   python3 -m pip --version
   ```

   **Linux:**
   ```bash
   # Verify Python 3.11
   python3.11 --version
   
   # If not installed:
   sudo apt-get update
   sudo apt-get install python3.11 python3.11-venv python3.11-pip
   
   # Verify PATH
   python3.11 -m pip --version
   ```

   **Quick Verification:**
   ```bash
   # Windows
   .\scripts\check_python.ps1
   
   # macOS/Linux
   ./scripts/check_python.sh
   ```

   **Troubleshooting PATH Issues:**
   - Windows: Add Python installation directory to System PATH
   - macOS/Linux: Ensure `python3.11` is accessible or create symlink
   - Restart terminal after PATH changes
   - See [PYTHON_SETUP.md](../PYTHON_SETUP.md) for detailed PATH setup instructions

2. **Install Terraform** (>= 1.5.0)
   - Download from https://www.terraform.io/downloads
   - Or use package manager:
     - Windows: `choco install terraform`
     - macOS: `brew install terraform`
     - Linux: `sudo apt-get install terraform`

3. **Configure AWS Credentials**
   ```bash
   aws configure
   # Or use environment variables:
   # AWS_ACCESS_KEY_ID
   # AWS_SECRET_ACCESS_KEY
   # AWS_DEFAULT_REGION
   ```

4. **Install Python Dependencies** (for Lambda functions)
   
   **Important**: Ensure Python 3.11 is in PATH before running:
   ```bash
   # Verify Python first
   python --version  # Windows
   python3 --version  # macOS/Linux
   
   # Then install dependencies
   # On Windows
   .\scripts\install_lambda_deps.ps1
   
   # On Linux/macOS
   ./scripts/install_lambda_deps.sh
   ```

## Step-by-Step Deployment

### 1. Navigate to Terraform Directory

```bash
cd terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider and initializes the backend.

### 3. Configure Variables (Optional)

Create `terraform.tfvars` from the example:

```bash
# On Windows
copy terraform.tfvars.example terraform.tfvars

# On Linux/macOS
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:

```hcl
aws_region = "us-east-1"
project_name = "financial-news"
news_ingestion_schedule = "rate(5 minutes)"
```

### 4. Review the Plan

```bash
terraform plan
```

This shows what resources will be created without actually creating them.

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will:
- Create DynamoDB tables
- Create Lambda functions
- Set up API Gateway (WebSocket + REST)
- Configure IAM roles and permissions
- Set up CloudWatch event rules

**Deployment time**: ~5-10 minutes

### 6. Get Outputs

After successful deployment:

```bash
terraform output
```

Save the endpoints:
- `websocket_api_endpoint`: WebSocket URL for real-time updates
- `rest_api_endpoint`: REST API URL for fetching news

### 7. Configure Frontend

Update `frontend/src/App.js` with the endpoints:

```javascript
const WS_ENDPOINT = 'wss://YOUR_WEBSOCKET_ENDPOINT';
const REST_API_ENDPOINT = 'https://YOUR_REST_API_ENDPOINT';
```

## Verification

### Test News Ingestion

Manually trigger the Lambda:

```bash
aws lambda invoke \
  --function-name financial-news-ingestion \
  --payload '{}' \
  response.json

cat response.json
```

### Check CloudWatch Logs

```bash
# News Ingestion logs
aws logs tail /aws/lambda/financial-news-ingestion --follow

# Bedrock Analysis logs
aws logs tail /aws/lambda/financial-news-bedrock-analysis --follow
```

### Verify DynamoDB Tables

```bash
# Check news articles table
aws dynamodb scan --table-name financial-news-articles --limit 5

# Check connections table
aws dynamodb scan --table-name financial-news-connections --limit 5
```

## Updating Resources

### Update Lambda Code

After modifying Lambda functions:

```bash
# Reinstall dependencies if needed
.\scripts\install_lambda_deps.ps1

# Apply changes
terraform apply
```

### Update Infrastructure

Modify `.tf` files and run:

```bash
terraform plan
terraform apply
```

## Destroying Resources

**⚠️ WARNING**: This will delete ALL resources including data!

```bash
terraform destroy
```

## Troubleshooting

### "Error creating Lambda function"

- Ensure Python dependencies are installed in each Lambda directory
- Check that `lambda_packages/` directory exists
- Verify IAM permissions

### "API Gateway integration failed"

- Check Lambda function permissions
- Verify route configurations
- Review API Gateway execution logs

### "DynamoDB stream not found"

- Ensure stream is enabled on the table
- Check event source mapping status
- Verify Lambda permissions for DynamoDB

### "Bedrock access denied"

1. Navigate to Amazon Bedrock in AWS Console
2. Request access to Claude models
3. Wait for approval
4. Verify IAM role has `bedrock:InvokeModel` permission

## Cost Estimation

After deployment, monitor costs in AWS Cost Explorer:

- **Lambda**: ~$5-20/month
- **DynamoDB**: ~$1-5/month (on-demand)
- **API Gateway**: ~$3-10/month
- **Bedrock**: Pay per token usage
- **CloudWatch**: Minimal

## Next Steps

1. Set up CloudWatch alarms for monitoring
2. Configure auto-scaling if using provisioned DynamoDB
3. Set up CI/CD pipeline
4. Configure backup/retention policies
5. Add custom domain to API Gateway

## State Management

For team collaboration, configure remote state:

1. Create S3 bucket:
   ```bash
   aws s3 mb s3://your-terraform-state-bucket
   ```

2. Enable versioning:
   ```bash
   aws s3api put-bucket-versioning \
     --bucket your-terraform-state-bucket \
     --versioning-configuration Status=Enabled
   ```

3. Uncomment backend block in `main.tf`:
   ```hcl
   backend "s3" {
     bucket = "your-terraform-state-bucket"
     key    = "financial-news-analysis/terraform.tfstate"
     region = "us-east-1"
   }
   ```

4. Reinitialize:
   ```bash
   terraform init -migrate-state
   ```

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review Terraform state: `terraform show`
3. See main `README.md` for architecture details


# Quick Start Guide

## 1. Prerequisites (10 minutes)

### 1.1 Install Python 3.11

This project requires Python 3.11 or higher. Verify installation:

> **📖 Need detailed help?** See [PYTHON_SETUP.md](PYTHON_SETUP.md) for comprehensive installation instructions.

**Windows:**
```powershell
python --version
# Should show: Python 3.11.x or higher

# If not found, download from https://www.python.org/downloads/
# IMPORTANT: Check "Add Python to PATH" during installation
```

**macOS:**
```bash
python3 --version
# Should show: Python 3.11.x or higher

# If not installed or wrong version:
brew install python@3.11
```

**Linux:**
```bash
python3 --version
# Should show: Python 3.11.x or higher

# If not installed:
sudo apt-get update
sudo apt-get install python3.11 python3.11-venv python3.11-pip
```

**Verify PATH:**
```bash
# Quick check (recommended)
# Windows
.\scripts\check_python.ps1

# macOS/Linux
./scripts/check_python.sh

# Or manually
# Windows
python -m pip --version

# macOS/Linux
python3 -m pip --version

# If you see "command not found", Python is not in PATH
# See PYTHON_SETUP.md for detailed PATH setup instructions
```

### 1.2 Install AWS SAM CLI

> **⚠️ Required for SAM deployment**: This is only needed if using AWS SAM/CloudFormation. If using Terraform, skip this step.

**Prerequisites:**
- Python 3.11+ must be installed (see step 1.1)
- Verify Python is working: `python --version` or `python3 --version`

**Installation:**

**Windows:**
```powershell
# Install SAM CLI
python -m pip install aws-sam-cli

# Verify installation
sam --version

# If "sam: command not found", add Python Scripts to PATH:
# Python Scripts directory: C:\Users\YourUsername\AppData\Local\Programs\Python\Python311\Scripts
# Then restart terminal
```

**macOS/Linux:**
```bash
# Option 1: Using pip (recommended)
python3 -m pip install aws-sam-cli

# Option 2: Using Homebrew (macOS only)
brew install aws-sam-cli

# Option 3: Using pipx (avoid conflicts)
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install aws-sam-cli

# Verify installation
sam --version
```

**Verify Installation:**

**Quick check (recommended):**
```bash
# Windows
.\scripts\check_sam.ps1

# macOS/Linux
./scripts/check_sam.sh
```

**Manual verification:**
```bash
# Check version
sam --version
# Should show: SAM CLI, version X.X.X

# Test help command
sam --help

# If command not found:
# Windows: Add Python Scripts directory to PATH
# macOS/Linux: Add ~/.local/bin to PATH or use pipx
```

**Troubleshooting:**
- If `sam` command not found after installation:
  - **Windows**: Python Scripts directory may not be in PATH. Add `C:\Python311\Scripts` to PATH and restart terminal
  - **macOS/Linux**: Add `~/.local/bin` to PATH or install using `pipx` (recommended)
- See README.md for detailed troubleshooting

### 1.3 Verify AWS CLI

AWS CLI must be installed and configured before deployment.

**Check if AWS CLI is installed:**
```bash
aws --version
# Should show: aws-cli/X.X.X
```

**If not installed:**
- **Windows**: Download from https://aws.amazon.com/cli/ or use `pip install awscli`
- **macOS**: `brew install awscli`
- **Linux**: `sudo apt-get install awscli` or use pip

**Configure AWS credentials:**
```bash
aws configure
# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key  
# - Default region name (e.g., us-east-1)
# - Default output format (json)

# Verify configuration
aws configure list
# Should show your AWS credentials and region
```

### 1.4 Install Node.js Dependencies

```bash
cd frontend
npm install
cd ..
```

## 2. Get Free News API Keys (10 minutes)

### Option A: NewsAPI.org (Recommended)
1. Visit https://newsapi.org/register
2. Sign up for free account (100 requests/day)
3. Copy your API key
4. Store it:
   ```bash
   aws ssm put-parameter \
     --name /financial-news/news-api-key \
     --value "YOUR_NEWSAPI_KEY" \
     --type SecureString
   ```

### Option B: Alpha Vantage
1. Visit https://www.alphavantage.co/support/#api-key
2. Sign up for free account (5 calls/min, 500/day)
3. Copy your API key
4. Store it:
   ```bash
   aws ssm put-parameter \
     --name /financial-news/alphavantage-api-key \
     --value "YOUR_ALPHAVANTAGE_KEY" \
     --type SecureString
   ```

## 3. Enable Amazon Bedrock (5 minutes)

1. Open AWS Console → Amazon Bedrock
2. Navigate to "Model access" in left sidebar
3. Request access to:
   - Claude 3 Sonnet (or Claude 3.5 Sonnet if available)
4. Wait for approval (usually instant for free tier)

## 4. Deploy Backend (10 minutes)

```bash
# Build and deploy
sam build
sam deploy --guided

# First time deployment will ask:
# - Stack name: financial-news-analysis
# - AWS Region: us-east-1 (recommended for Bedrock)
# - Confirm changes: Yes
# - Allow IAM changes: Yes
# - Disable rollback: No (default)
# - NewsIngestionFunction has no authentication. Is this okay? [y/N]: y
#   (Answer 'y' to allow deployment without API key auth - you can add auth later if needed)
```

**Note**: If you see "Security Constraints Not Satisfied!":
- The ingestion endpoint `/ingest` is configured without authentication by default
- This is fine for development/testing
- Answer 'y' when asked: "NewsIngestionFunction has no authentication. Is this okay?"
- For production, consider adding API key authentication (see template.yaml)

**Save the outputs:**
- `WebSocketApiEndpoint` (starts with `wss://`)
- Note the REST API endpoint (check CloudFormation outputs)

## 5. Configure Frontend (2 minutes)

Edit `frontend/src/App.js` and update these lines:

```javascript
const WS_ENDPOINT = 'wss://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod';
const REST_API_ENDPOINT = 'https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod';
```

Or create `frontend/.env`:
```
REACT_APP_WS_ENDPOINT=wss://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod
REACT_APP_REST_API_ENDPOINT=https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod
```

## 6. Run Frontend

```bash
cd frontend
npm start
```

Open http://localhost:3000

## 7. Test the System

1. **Trigger news ingestion manually:**
   ```bash
   aws lambda invoke \
     --function-name NewsIngestion \
     --payload '{}' \
     response.json
   ```

2. **Check CloudWatch logs:**
   ```bash
   aws logs tail /aws/lambda/NewsIngestion --follow
   ```

3. **Verify articles in DynamoDB:**
   ```bash
   aws dynamodb scan --table-name FinancialNewsArticles --limit 5
   ```

## Expected Flow

1. **Every 5 minutes**: News ingestion Lambda runs
2. **Fetches news** from configured APIs
3. **Saves to DynamoDB** with status `pending_analysis`
4. **DynamoDB stream triggers** Bedrock analysis Lambda
5. **Bedrock analyzes** sentiment and identifies tickers
6. **Trading strategies generated** automatically
7. **WebSocket broadcasts** updates to connected clients
8. **Frontend displays** new articles in real-time

## Troubleshooting

### No news appearing?
- Check CloudWatch logs for errors
- Verify API keys are stored in SSM correctly
- Ensure Bedrock access is granted

### WebSocket not connecting?
- Verify endpoint URL is correct
- Check API Gateway WebSocket logs
- Ensure frontend is using `wss://` (not `ws://`)

### Bedrock errors?
- Confirm model access in Bedrock console
- Check Lambda execution role has `bedrock:InvokeModel` permission
- Verify region (Bedrock may not be available in all regions)

## Next Steps

- Customize trading strategies in `src/bedrock_analysis/lambda_function.py`
- Add more news sources in `src/news_ingestion/lambda_function.py`
- Adjust news fetch frequency in `template.yaml`
- Deploy frontend to S3 + CloudFront for production

## Cost Optimization

- Reduce Lambda memory if needed
- Use DynamoDB on-demand billing
- Monitor Bedrock token usage
- Set up CloudWatch alarms for costs


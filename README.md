# Financial News Analysis System

A serverless AWS solution that continuously streams financial news articles, analyzes them for sentiment and affected S&P 500 tickers using Amazon Bedrock, and provides real-time actionable trading strategies via a web dashboard.

## Architecture

- **News Ingestion**: Lambda function that fetches news from free APIs (NewsAPI, Alpha Vantage) every 5 minutes
- **Bedrock Analysis**: Lambda function triggered by DynamoDB stream that analyzes articles for sentiment and identifies affected S&P 500 tickers
- **Trading Strategies**: Automatically generates options trading strategies based on sentiment
- **Real-time Updates**: WebSocket API Gateway for live updates to frontend
- **Frontend**: React dashboard displaying news headlines with sentiment analysis and trading recommendations

## Features

- 📰 Continuous news streaming from multiple free sources
- 🤖 AI-powered sentiment analysis using Amazon Bedrock (Claude)
- 📊 Automatic S&P 500 ticker identification
- 💡 Actionable options trading strategies
- ⚡ Real-time updates via WebSocket
- 🎨 Modern, responsive React frontend

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Python 3.11+ installed and in PATH (see [Python Installation](#python-311-installation))
- AWS SAM CLI installed and in PATH (see [AWS SAM CLI Installation](#aws-sam-cli-installation)) - **Required only for SAM/CloudFormation deployment**
- Node.js and npm installed
- Amazon Bedrock access (request access in AWS Console if needed)

> **Note**: AWS SAM CLI is only required if you're using **Option A: AWS SAM (CloudFormation)** deployment. If you're using **Option B: Terraform**, you do not need SAM CLI.

### Python 3.11 Installation

This project requires Python 3.11 or higher. Follow these steps to install and verify:

> **📖 Detailed Installation Guide**: See [PYTHON_SETUP.md](PYTHON_SETUP.md) for comprehensive installation instructions and troubleshooting.

#### Windows

1. **Download Python 3.11+**
   - Visit https://www.python.org/downloads/
   - Download Python 3.11 or newer
   - **Important**: During installation, check "Add Python to PATH"

2. **Verify Installation**
   ```powershell
   python --version
   # Should show: Python 3.11.x or higher
   
   python -m pip --version
   # Should show pip version
   ```

3. **If Python is not in PATH:**
   ```powershell
   # Find Python installation (usually in AppData or Program Files)
   # Add to PATH manually:
   # 1. Search "Environment Variables" in Windows
   # 2. Edit "Path" variable
   # 3. Add: C:\Users\YourUsername\AppData\Local\Programs\Python\Python311
   # 4. Add: C:\Users\YourUsername\AppData\Local\Programs\Python\Python311\Scripts
   # 5. Restart terminal
   ```

#### macOS

1. **Using Homebrew (Recommended)**
   ```bash
   brew install python@3.11
   
   # Verify
   python3.11 --version
   
   # Make it default python3
   brew link --overwrite python@3.11
   ```

2. **Or Download from python.org**
   - Visit https://www.python.org/downloads/macos/
   - Download Python 3.11+ installer
   - Run installer and follow prompts
   - Verify: `python3 --version`

#### Linux

1. **Ubuntu/Debian**
   ```bash
   sudo apt-get update
   sudo apt-get install python3.11 python3.11-venv python3.11-pip
   
   # Verify
   python3.11 --version
   
   # Create symlink if needed
   sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
   ```

2. **CentOS/RHEL/Fedora**
   ```bash
   sudo dnf install python3.11 python3.11-pip
   # or
   sudo yum install python3.11 python3.11-pip
   
   # Verify
   python3.11 --version
   ```

#### Verify PATH Configuration

**Quick Check Script:**
```bash
# Windows
.\scripts\check_python.ps1

# macOS/Linux
./scripts/check_python.sh
```

Or verify manually:

```bash
# Windows (PowerShell or CMD)
python --version
python -m pip --version

# macOS/Linux
python3 --version
python3 -m pip --version

# If you see "command not found", Python is not in PATH
# Follow PATH configuration steps above
```

#### Troubleshooting PATH Issues

**Windows:**
- If `python` command not found, use `py -3.11` or full path: `C:\Python311\python.exe`
- Ensure Python installation directory is in System or User PATH
- Restart terminal/IDE after modifying PATH

**macOS/Linux:**
- If `python3` points to wrong version, use `python3.11` explicitly
- Check with `which python3` to see current Python location
- Update shell profile (`~/.bashrc`, `~/.zshrc`) if needed:
  ```bash
  alias python3=python3.11
  ```

### AWS SAM CLI Installation

> **⚠️ Required only for SAM/CloudFormation deployment**: If you're using Terraform, skip this section.

AWS SAM CLI is used for building and deploying serverless applications using AWS SAM templates. Follow these steps:

#### Prerequisites for SAM CLI

- Python 3.11+ installed (see [Python Installation](#python-311-installation) above)
- pip (comes with Python)

#### Installation Methods

**Option 1: Using pip (Recommended)**

```bash
# Windows
python -m pip install aws-sam-cli

# macOS/Linux
python3 -m pip install aws-sam-cli

# Or upgrade if already installed
python -m pip install --upgrade aws-sam-cli  # Windows
python3 -m pip install --upgrade aws-sam-cli  # macOS/Linux
```

**Option 2: Using Homebrew (macOS/Linux only)**

```bash
brew install aws-sam-cli
```

**Option 3: Using pipx (Recommended for avoiding conflicts)**

```bash
# Install pipx first (if not installed)
python -m pip install --user pipx
python -m pipx ensurepath

# Install SAM CLI using pipx
pipx install aws-sam-cli
```

#### Verify Installation

```bash
# Check SAM CLI version
sam --version
# Should show: SAM CLI, version X.X.X

# Check if SAM CLI is in PATH
which sam  # macOS/Linux
where sam  # Windows PowerShell

# Test SAM CLI commands
sam --help
```

**Quick Check Script:**
```bash
# Windows
.\scripts\check_sam.ps1

# macOS/Linux
./scripts/check_sam.sh
```

#### Troubleshooting SAM CLI Installation

**Issue: "sam: command not found"**

**Windows:**
- SAM CLI should be in: `C:\Users\YourUsername\AppData\Local\Programs\Python\Python311\Scripts\`
- If not found, add Python Scripts directory to PATH (see Python installation above)
- Restart terminal after adding to PATH
- Alternative: Use full path `C:\Python311\Scripts\sam.exe` or reinstall with `--user` flag:
  ```powershell
  python -m pip install --user aws-sam-cli
  ```

**macOS/Linux:**
- If installed with pip, SAM CLI is in: `~/.local/bin/` or `$HOME/.local/bin/`
- Add to PATH if not already:
  ```bash
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
  source ~/.zshrc
  ```
- Or use pipx (recommended) which handles PATH automatically

**Issue: "SAM CLI version is outdated"**

```bash
# Update SAM CLI
python -m pip install --upgrade aws-sam-cli  # Windows
python3 -m pip install --upgrade aws-sam-cli  # macOS/Linux

# Or if using pipx
pipx upgrade aws-sam-cli
```

**Issue: "Permission denied" or installation fails**

**Windows:**
- Run PowerShell as Administrator
- Or install with `--user` flag:
  ```powershell
  python -m pip install --user aws-sam-cli
  ```

**macOS/Linux:**
- Use `--user` flag to install in user directory:
  ```bash
  python3 -m pip install --user aws-sam-cli
  ```
- Or use pipx to avoid permission issues

#### Verify SAM CLI Works

After installation, test with:

```bash
# Check version
sam --version

# Test build command (will fail but shows it's working)
sam build --help

# Verify it can access AWS (if configured)
sam validate --template template.yaml
```

## Deployment Options

This project supports two deployment methods:

### Option A: AWS SAM (CloudFormation)
See `QUICKSTART.md` for SAM deployment instructions.

### Option B: Terraform (Recommended)
See `terraform/README.md` and `terraform/DEPLOYMENT.md` for Terraform deployment.

Quick start with Terraform:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Setup

### 1. Get Free News API Keys

The system supports multiple news sources:

1. **NewsAPI.org** (Recommended)
   - Sign up at https://newsapi.org
   - Get your free API key (100 requests/day on free tier)
   - Store key: `aws ssm put-parameter --name /financial-news/news-api-key --value YOUR_KEY --type String`

2. **Alpha Vantage**
   - Sign up at https://www.alphavantage.co/support/#api-key
   - Get your free API key (5 API calls/min, 500/day)
   - Store key: `aws ssm put-parameter --name /financial-news/alphavantage-api-key --value YOUR_KEY --type String`

3. **Other Sources**
   - The code is extensible for other free news APIs

### 2. Configure Amazon Bedrock

1. Navigate to Amazon Bedrock in AWS Console
2. Request access to Claude models (Claude 3 Sonnet recommended)
3. Ensure your Lambda execution role has `bedrock:InvokeModel` permission (handled by template)

### 3. Deploy Backend

```bash
# Build the SAM application
sam build

# Deploy with guided prompts (first time)
sam deploy --guided

# Subsequent deployments
sam deploy

# Note the outputs:
# - WebSocketApiEndpoint
# - RestApiEndpoint
```

### 4. Configure Frontend

1. Update `frontend/src/App.js` with your API endpoints:

```javascript
const WS_ENDPOINT = 'wss://your-api-id.execute-api.us-east-1.amazonaws.com/prod';
const REST_API_ENDPOINT = 'https://your-api-id.execute-api.us-east-1.amazonaws.com/prod';
```

Or use environment variables:
```bash
cd frontend
echo "REACT_APP_WS_ENDPOINT=wss://your-api-id.execute-api.us-east-1.amazonaws.com/prod" > .env
echo "REACT_APP_REST_API_ENDPOINT=https://your-api-id.execute-api.us-east-1.amazonaws.com/prod" >> .env
```

### 5. Run Frontend

```bash
cd frontend
npm install
npm start
```

The app will open at http://localhost:3000

## Configuration

### Environment Variables (Lambda)

The Lambda functions can use environment variables or SSM parameters:

- `NEWS_API_KEY`: NewsAPI.org API key
- `ALPHAVANTAGE_API_KEY`: Alpha Vantage API key
- `TABLE_NAME`: DynamoDB table name (auto-set)
- `WS_API_ENDPOINT`: WebSocket endpoint (auto-set)

### Schedule Configuration

News ingestion runs every 5 minutes by default. To change:
- Edit `template.yaml` → `ScheduledEvent` → `Schedule: rate(5 minutes)`

### Bedrock Model

Default model is Claude 3 Sonnet. To change:
- Edit `src/bedrock_analysis/lambda_function.py` → `BEDROCK_MODEL_ID`

## API Endpoints

### REST API

- `GET /news` - Get all analyzed articles (query params: `limit`, `status`)
- `GET /news/{articleId}` - Get specific article

### WebSocket API

Connect to WebSocket endpoint and send:
```json
{"action": "get_latest"}
```

Receive messages:
- `news_update` - New article analyzed
- `latest_news` - Response to get_latest action

## Project Structure

```
.
├── template.yaml                 # SAM template
├── src/
│   ├── news_ingestion/          # Fetches news from APIs
│   ├── bedrock_analysis/        # Analyzes with Bedrock
│   ├── websocket_connect/       # WebSocket connection handler
│   ├── websocket_disconnect/    # WebSocket disconnection handler
│   ├── websocket_message/       # WebSocket message handler
│   └── get_news/                # REST API handler
└── frontend/                     # React application
    ├── src/
    │   ├── App.js
    │   └── components/
    │       ├── NewsCard.js
    │       └── ConnectionStatus.js
    └── public/
```

## Trading Strategies

Based on sentiment, the system recommends:

**Bullish:**
- Long call
- Short put
- Short put credit spread
- Long call debit spread
- Bull call spread
- Covered call

**Bearish:**
- Long put
- Short call
- Short call credit spread
- Long put debit spread
- Bear put spread
- Protective put

**Neutral:**
- Iron condor
- Butterfly spread
- Calendar spread
- Straddle/strangle

## Cost Estimation

Approximate monthly costs (AWS Free Tier excluded):

- **Lambda**: ~$5-20/month (depending on usage)
- **DynamoDB**: ~$1-5/month (on-demand pricing)
- **API Gateway**: ~$3-10/month (WebSocket + REST)
- **Bedrock**: ~$0.003 per 1K input tokens, ~$0.015 per 1K output tokens
- **CloudWatch**: Minimal

Total: ~$10-40/month (can be optimized with Reserved Capacity)

## Troubleshooting

### News not appearing
- Check CloudWatch logs for Lambda functions
- Verify API keys are set correctly
- Check DynamoDB table for articles with `status: pending_analysis`

### WebSocket connection issues
- Verify WebSocket endpoint is correct
- Check API Gateway WebSocket logs
- Ensure CORS is configured (if accessing from different domain)

### Bedrock errors
- Verify Bedrock access is granted in AWS Console
- Check Lambda execution role has Bedrock permissions
- Verify model ID is correct and available in your region

## License

MIT

## Contributing

Contributions welcome! Please open an issue or submit a PR.


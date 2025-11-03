# Deployment Troubleshooting Guide

## Common Deployment Issues

### Error: "Security Constraints Not Satisfied!"

**Symptoms:**
```
NewsIngestionFunction has no authentication. Is this okay? [y/N]:
Error: Security Constraints Not Satisfied!
```

**Cause:**
The `NewsIngestionFunction` has an API endpoint (`/ingest`) without authentication configured. SAM CLI requires explicit acknowledgment for security.

**Solutions:**

#### Option 1: Allow No Authentication (Quick Fix for Development)

When prompted, answer **'y'** to the question:
```
NewsIngestionFunction has no authentication. Is this okay? [y/N]: y
```

This allows deployment with an unauthenticated endpoint. **Only use for development/testing.**

#### Option 2: Add API Key Authentication (Recommended for Production)

Edit `template.yaml` and update the `ApiEvent` section:

```yaml
ApiEvent:
  Type: Api
  Properties:
    Path: /ingest
    Method: post
    Auth:
      ApiKeyRequired: true
```

Then create an API key and usage plan (or use SAM's auto-created API keys).

#### Option 3: Use samconfig.toml to Pre-configure

Create or edit `samconfig.toml` and add:

```toml
[default.deploy.parameters]
parameter_overrides = []
confirm_changeset = true
resolve_s3 = true
allow_no_auth = true  # Allow functions without authentication
```

Then deploy without guided mode:
```bash
sam deploy
```

#### Option 4: Remove the API Event (If Not Needed)

If you don't need manual triggering via HTTP, you can remove the `ApiEvent` from `template.yaml`:

```yaml
Events:
  ScheduledEvent:
    Type: Schedule
    Properties:
      Schedule: rate(5 minutes)
      Enabled: true
  # Remove ApiEvent section if not needed
```

### Error: "Template validation error"

**Symptoms:**
```
Error: [InvalidResourceException] Resource with id [X] is invalid
```

**Common Causes:**
- Missing environment variables
- Incorrect resource references
- Syntax errors in YAML

**Solution:**
1. Validate template:
   ```bash
   sam validate
   ```
2. Check for YAML syntax errors
3. Ensure all `!Ref` and `!GetAtt` references are correct
4. Verify all required properties are present

### Error: "Access Denied" or IAM Permission Errors

**Symptoms:**
```
User: arn:aws:iam::XXX:user/XXX is not authorized to perform: XXX
```

**Cause:**
Your AWS credentials don't have sufficient permissions.

**Solution:**
1. Ensure your AWS user/role has these permissions:
   - CloudFormation (full access)
   - Lambda (full access)
   - API Gateway (full access)
   - DynamoDB (full access)
   - IAM (for creating roles)
   - Bedrock (InvokeModel)
   - SSM (ReadParameter for API keys)

2. Or use an IAM user with AdministratorAccess for development

3. Check your AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```

### Error: "Bedrock model access denied"

**Symptoms:**
```
An error occurred (AccessDeniedException) when calling the InvokeModel operation
```

**Cause:**
Bedrock model access not granted or Lambda role doesn't have permissions.

**Solution:**
1. Go to AWS Console → Amazon Bedrock → Model access
2. Request access to Claude models (if not already done)
3. Verify Lambda execution role has `bedrock:InvokeModel` permission (should be in template)
4. Check the region - Bedrock may not be available in all regions

### Error: "DynamoDB Stream not found"

**Symptoms:**
```
ResourceNotFoundException: Stream not found
```

**Cause:**
DynamoDB stream not enabled or table created before stream.

**Solution:**
1. Check `template.yaml` has `StreamSpecification`:
   ```yaml
   StreamSpecification:
     StreamViewType: NEW_AND_OLD_IMAGES
   ```
2. Delete and recreate the stack if stream wasn't enabled initially

### Error: "ModuleNotFoundError" or Missing Dependencies

**Symptoms:**
Lambda function fails with import errors.

**Cause:**
Python dependencies not included in deployment package.

**Solution:**
1. Install dependencies locally in each Lambda directory:
   ```bash
   cd src/news_ingestion
   python -m venv venv
   source venv/bin/activate  # or venv\Scripts\activate on Windows
   pip install -r requirements.txt
   ```

2. Or use `sam build` which should package dependencies automatically

3. Check `requirements.txt` exists in each Lambda directory

### Error: "Connection timeout" or WebSocket Issues

**Symptoms:**
WebSocket connections fail or timeout.

**Solution:**
1. Verify WebSocket API endpoint is correct
2. Check API Gateway stage is deployed
3. Verify Lambda permissions for WebSocket API
4. Check CloudWatch logs for connection errors
5. Ensure frontend uses `wss://` (not `ws://`)

### Error: "No news appearing"

**Symptoms:**
Frontend shows no articles.

**Troubleshooting Steps:**
1. **Check News Ingestion Lambda:**
   ```bash
   aws lambda invoke --function-name NewsIngestion response.json
   cat response.json
   ```

2. **Check CloudWatch Logs:**
   ```bash
   aws logs tail /aws/lambda/NewsIngestion --follow
   ```

3. **Verify API Keys in SSM:**
   ```bash
   aws ssm get-parameter --name /financial-news/news-api-key --with-decryption
   ```

4. **Check DynamoDB Table:**
   ```bash
   aws dynamodb scan --table-name FinancialNewsArticles --limit 5
   ```

5. **Check Bedrock Analysis Lambda:**
   ```bash
   aws logs tail /aws/lambda/BedrockAnalysis --follow
   ```

### Error: "sam deploy --guided" hangs or times out

**Solution:**
1. Check your internet connection
2. Verify AWS credentials are valid
3. Try deploying with `--no-progressbar` flag
4. Check CloudFormation console for stuck resources

### Error: "Stack already exists"

**Symptoms:**
```
Error: [StackExistsException] Stack [financial-news-analysis] already exists
```

**Solution:**
1. Delete existing stack:
   ```bash
   aws cloudformation delete-stack --stack-name financial-news-analysis
   ```

2. Wait for deletion to complete, then redeploy

3. Or update existing stack:
   ```bash
   sam deploy  # (not --guided)
   ```

## Quick Diagnostic Commands

```bash
# Check SAM CLI version
sam --version

# Validate template
sam validate

# Check AWS credentials
aws sts get-caller-identity

# List Lambda functions
aws lambda list-functions

# Check CloudFormation stacks
aws cloudformation list-stacks

# View stack events
aws cloudformation describe-stack-events --stack-name financial-news-analysis

# Test Lambda function
aws lambda invoke --function-name NewsIngestion --payload '{}' response.json
```

## Getting Help

1. Check CloudWatch Logs for detailed error messages
2. Review CloudFormation events in AWS Console
3. Validate SAM template: `sam validate`
4. Check AWS service limits and quotas
5. Review this troubleshooting guide for common issues

## Prevention Tips

- Always run `sam validate` before deploying
- Test Lambda functions locally first
- Use `sam build` to catch dependency issues early
- Enable detailed CloudWatch logging
- Test API endpoints after deployment
- Review IAM permissions before deployment


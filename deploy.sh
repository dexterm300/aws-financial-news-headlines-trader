#!/bin/bash

# Deployment script for Financial News Analysis System

echo "🚀 Deploying Financial News Analysis System..."

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo "❌ AWS SAM CLI is not installed. Install it with: pip install aws-sam-cli"
    exit 1
fi

# Build the application
echo "📦 Building SAM application..."
sam build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Deploy
echo "☁️  Deploying to AWS..."
sam deploy

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Get your API endpoints from the deployment outputs"
echo "2. Update frontend/src/App.js with the endpoints"
echo "3. Run 'cd frontend && npm install && npm start'"


# GitHub Repository Setup

Quick guide to push your project to GitHub.

## Step 1: Install Git (if needed)
Download from: https://git-scm.com/download/win

## Step 2: Initialize and Commit

```bash
# Initialize git repository
git init

# Configure git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Financial News Analysis System"
```

## Step 3: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `og-market-report` (or your choice)
3. Description: "Serverless AWS solution for real-time financial news analysis"
4. Choose Public or Private
5. **DO NOT** check "Add a README file" (we already have one)
6. Click "Create repository"

## Step 4: Push to GitHub

After creating the repository, GitHub will show you commands. Use these:

```bash
# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/og-market-report.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

## Authentication

When pushing, you'll need to authenticate:

**Option 1: Personal Access Token (Recommended)**
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `repo` scope
3. Copy the token
4. Use token as password when pushing (username is your GitHub username)

**Option 2: GitHub CLI**
```bash
# Install GitHub CLI and authenticate
gh auth login
git push -u origin main
```

## Quick Commands Reference

```bash
# Check status
git status

# Add changes
git add .

# Commit
git commit -m "Your commit message"

# Push
git push

# View remote
git remote -v
```

## That's It!

Your code is now on GitHub. You can share the repository URL with others or continue development.


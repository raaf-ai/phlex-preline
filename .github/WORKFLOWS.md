# GitHub Actions Workflows

This document describes the GitHub Actions workflows configured for this repository.

## Required Workflows

### CI (`.github/workflows/ci.yml`)
- **Purpose**: Run tests and linting on all pushes and pull requests
- **Requirements**: None
- **Status**: ✅ Always enabled

### Release (`.github/workflows/release.yml`)
- **Purpose**: Publish gem to RubyGems when a version tag is pushed
- **Requirements**: `RUBYGEMS_API_KEY` secret must be configured
- **Status**: ✅ Always enabled

## Optional Workflows

### Security (`.github/workflows/security.yml`)
- **Purpose**: Run Brakeman and bundle-audit security scans
- **Requirements**: None
- **Status**: ✅ Always enabled

### Dependency Review (`.github/workflows/dependency-review.yml`)
- **Purpose**: Review dependency changes in pull requests
- **Requirements**: GitHub Advanced Security (only works on public repos or with Advanced Security enabled)
- **Status**: ⚠️ Only runs on public repositories

### Version Check (`.github/workflows/version-check.yml`)
- **Purpose**: Verify version bumps and CHANGELOG updates
- **Requirements**: None
- **Status**: ✅ Always enabled

### Stale (`.github/workflows/stale.yml`)
- **Purpose**: Automatically close stale issues and PRs
- **Requirements**: None
- **Status**: ✅ Always enabled

## Removed Workflows

### CodeQL Analysis
- **Reason**: Requires GitHub Advanced Security which is not available for private repositories
- **Alternative**: Use the Security workflow with Brakeman instead

## Setting up Secrets

To enable gem publishing, add the following secret to your repository:

1. Go to Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Name: `RUBYGEMS_API_KEY`
4. Value: Your RubyGems API key (get it from https://rubygems.org/profile/api_keys)
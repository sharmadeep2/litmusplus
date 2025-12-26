# Litmus++ Enhanced Frontend Build Script for Windows
# This script builds the custom Litmus++ frontend Docker image

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🔨 Building Litmus++ Custom Frontend" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "✓ Checking Docker status..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
}
catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Navigate to project directory
$ProjectDir = Split-Path $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

Write-Host "📁 Working directory: $PWD" -ForegroundColor Blue
Write-Host ""

# Build custom frontend image
Write-Host "🐳 Building Litmus++ frontend Docker image..." -ForegroundColor Yellow
try {
    docker build -t litmusplus/frontend:3.24.0-plus ./custom-frontend
    Write-Host "✅ Docker image built successfully!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to build Docker image" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Tag image for different purposes
Write-Host "🏷️  Tagging image..." -ForegroundColor Yellow
docker tag litmusplus/frontend:3.24.0-plus litmusplus/frontend:latest

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🎉 Build Complete!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Available Images:" -ForegroundColor Yellow
docker images | findstr litmusplus
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Blue
Write-Host "   1. Run: .\update-litmus-plus.ps1" -ForegroundColor White
Write-Host "   2. Or manually upgrade Helm deployment" -ForegroundColor White
Write-Host ""
Write-Host "💡 The custom image 'litmusplus/frontend:3.24.0-plus' is ready!" -ForegroundColor Green

Read-Host "Press Enter to continue"
@echo off
REM Litmus++ Enhanced Frontend Build Script for Windows Command Prompt

echo ===============================================
echo 🔨 Building Litmus++ Custom Frontend
echo ===============================================
echo.

REM Check if Docker is running
echo ✓ Checking Docker status...
docker version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)
echo ✅ Docker is running
echo.

REM Navigate to project directory
cd /d "%~dp0"
echo 📁 Working directory: %CD%
echo.

REM Build custom frontend image
echo 🐳 Building Litmus++ frontend Docker image...
docker build -t litmusplus/frontend:3.24.0-plus .
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build Docker image
    pause
    exit /b 1
)
echo ✅ Docker image built successfully!

REM Tag image for different purposes
echo 🏷️  Tagging image...
docker tag litmusplus/frontend:3.24.0-plus litmusplus/frontend:latest

echo.
echo ===============================================
echo 🎉 Build Complete!
echo ===============================================
echo.
echo 📦 Available Images:
docker images | findstr litmusplus
echo.
echo 🚀 Next Steps:
echo    1. Run: update-litmus-plus.bat
echo    2. Or manually upgrade Helm deployment
echo.
echo 💡 The custom image 'litmusplus/frontend:3.24.0-plus' is ready!

pause
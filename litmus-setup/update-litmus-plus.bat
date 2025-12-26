@echo off
REM Litmus++ Deployment Update Script for Windows Command Prompt

echo ===============================================
echo 🚀 Updating to Litmus++ Enhanced Platform
echo ===============================================
echo.

REM Check if custom image exists
echo 🔍 Checking for custom Litmus++ image...
docker images --format "table {{.Repository}}:{{.Tag}}" | findstr "litmusplus/frontend:3.24.0-plus" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Custom image not found. Please build it first:
    echo    Run: build-frontend.bat
    pause
    exit /b 1
)
echo ✅ Custom image found!

REM Check if cluster is running
echo 🔍 Checking Kubernetes cluster...
kubectl get nodes >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Cluster not accessible. Please ensure cluster is running.
    pause
    exit /b 1
)
echo ✅ Cluster is accessible

REM Navigate to setup directory
cd /d "%~dp0"

REM Upgrade Helm deployment with custom values
echo 🎯 Upgrading Litmus deployment to Litmus++...
helm upgrade chaos litmuschaos/litmus --namespace=litmus --values litmus-values.yaml --wait --timeout=300s
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Helm upgrade failed
    echo Please check the error above and try again
    pause
    exit /b 1
)
echo ✅ Helm upgrade completed!

REM Wait for pods to be ready
echo ⏳ Waiting for Litmus++ pods to be ready...
kubectl wait --for=condition=ready pod --all -n litmus --timeout=300s
if %ERRORLEVEL% EQU 0 (
    echo ✅ All pods are ready!
) else (
    echo ⚠️  Some pods may still be starting. Check status manually.
)

REM Display pod status
echo.
echo 📊 Current Pod Status:
kubectl get pods -n litmus

echo.
echo ===============================================
echo 🎉 Litmus++ Update Complete!
echo ===============================================
echo.
echo 🌐 Access Information:
echo    URL: http://localhost:9091
echo    Platform: Litmus++ Enhanced Chaos Engineering
echo    Username: admin
echo    Password: litmus
echo.
echo 🔗 Start port forwarding:
echo    kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
echo.

pause
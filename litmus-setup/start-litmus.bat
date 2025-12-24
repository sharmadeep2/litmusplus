@echo off
REM LitmusChaos Testing Script

echo ===================================
echo 🚀 LitmusChaos Testing Environment
echo ===================================
echo.

REM Check if cluster is running
echo 📊 Checking Kubernetes Cluster:
kubectl get nodes
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Cluster not accessible. Please check Docker Desktop and Kind cluster.
    pause
    exit /b 1
)
echo.

REM Check Litmus pods
echo 🔍 LitmusChaos Pods Status:
kubectl get pods -n litmus
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Litmus not installed. Please reinstall using: helm install chaos litmuschaos/litmus --namespace=litmus --values litmus-values.yaml
    pause
    exit /b 1
)
echo.

REM Check demo application
echo 🎯 Demo Application Status:
kubectl get pods -n chaos-demo
if %ERRORLEVEL% NEQ 0 (
    echo 📝 Demo app not found. Creating nginx demo application...
    kubectl create namespace chaos-demo 2>nul
    kubectl create deployment nginx-app --image=nginx:latest --replicas=3 -n chaos-demo
    kubectl expose deployment nginx-app --port=80 --type=NodePort -n chaos-demo
    echo ⏳ Waiting for demo app to be ready...
    kubectl wait --for=condition=ready pod --all -n chaos-demo --timeout=120s
)
echo.

REM Start port forwarding
echo 🌐 Starting LitmusChaos UI...
echo ⚠️  Keep this window open to maintain access to LitmusChaos UI
echo 🔗 Access URL: http://localhost:9091
echo 🔑 Username: admin
echo 🔑 Password: litmus
echo.
echo Press Ctrl+C to stop the port forwarding and exit
echo.

REM Run port forward
kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
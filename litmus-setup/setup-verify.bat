@echo off
REM LitmusChaos Local Setup Verification Script for Windows

echo ===================================
echo 🚀 LitmusChaos Local Setup Complete
echo ===================================
echo.

REM Check cluster status
echo 📊 Kubernetes Cluster Status:
kubectl get nodes
echo.

REM Check Litmus pods
echo 🔍 Litmus Pods Status:
kubectl get pods -n litmus
echo.

REM Check services
echo 🌐 Litmus Services:
kubectl get services -n litmus
echo.

echo ✅ Setup Summary:
echo    • Kubernetes cluster: litmus-cluster (Kind)
echo    • Litmus namespace: litmus
echo    • Frontend access: http://localhost:9091
echo    • Default credentials: admin / litmus
echo.

echo 🔗 Access Instructions:
echo    1. Keep the port-forward running in another terminal:
echo       kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
echo    2. Open your browser and visit: http://localhost:9091
echo    3. Login with username: admin, password: litmus
echo.

echo 📚 Useful Commands:
echo    • View logs: kubectl logs -l app=chaos-litmus-frontend -n litmus
echo    • Scale down: kubectl scale deployment chaos-litmus-frontend --replicas=0 -n litmus
echo    • Scale up: kubectl scale deployment chaos-litmus-frontend --replicas=1 -n litmus
echo    • Uninstall: helm uninstall chaos -n litmus
echo    • Delete cluster: kind delete cluster --name litmus-cluster
echo.

echo 🎯 Next Steps:
echo    1. Create your first chaos experiment
echo    2. Explore the Chaos Hub for pre-built experiments
echo    3. Set up monitoring and observability
echo    4. Join the Litmus community on Slack
echo.
echo Happy Chaos Engineering! 🎭

pause
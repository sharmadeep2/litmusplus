@echo off
echo Starting Litmus++ with all required services...
echo.

echo Stopping any existing port forwarding...
taskkill /f /im kubectl.exe >nul 2>&1

echo Waiting for cleanup...
timeout /t 3 >nul

echo Starting port forwarding for all services...
start /min "Frontend" kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
timeout /t 2 >nul
start /min "Server" kubectl port-forward svc/chaos-litmus-server-service 9002:9002 -n litmus  
timeout /t 2 >nul
start /min "Auth" kubectl port-forward svc/chaos-litmus-auth-server-service 9003:9003 -n litmus
timeout /t 3 >nul

echo.
echo Checking services...
netstat -ano | findstr "909"

echo.
echo Testing frontend connectivity...
curl -s http://localhost:9091 | findstr "<title>" || echo Failed to get title

echo.
echo Litmus++ should now be accessible at:
echo Frontend: http://localhost:9091  
echo Username: admin
echo Password: litmus
echo.
echo Press any key to stop all port forwarding...
pause >nul

echo Stopping port forwarding...
taskkill /f /im kubectl.exe >nul 2>&1
echo Done!
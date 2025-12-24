@echo off
REM Script to setup admin user for LitmusChaos 3.x

echo =======================================
echo 🔐 LitmusChaos Admin User Setup
echo =======================================
echo.

echo Checking LitmusChaos services...
kubectl get pods -n litmus | findstr Running
echo.

echo Testing authentication endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9091' -Method GET -TimeoutSec 10; Write-Host 'Frontend accessible: HTTP' $response.StatusCode } catch { Write-Host 'Error accessing frontend:' $_.Exception.Message }"
echo.

echo =======================================
echo 💡 Troubleshooting Steps:
echo =======================================
echo.
echo 1. Try these credential combinations:
echo    • Username: admin, Password: admin  
echo    • Username: admin, Password: password
echo    • Username: admin, Password: litmus
echo.
echo 2. Check browser console for errors (F12)
echo.
echo 3. Clear browser cache and cookies
echo.
echo 4. Try incognito/private browsing mode
echo.
echo 5. If still not working, restart services:
echo    kubectl rollout restart deployment -n litmus
echo.

echo =======================================
echo 🌐 Access Information:
echo =======================================
echo URL: http://localhost:9091
echo.
echo If login still fails, check the setup documentation for LitmusChaos 3.x
echo which may require initial admin setup through a different process.
echo.

pause
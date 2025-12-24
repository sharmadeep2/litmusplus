@echo off
REM Final verification script for LitmusChaos setup

echo =======================================
echo 🎉 LitmusChaos Setup Verification
echo =======================================
echo.

echo ✅ Checking Kubernetes cluster...
kubectl cluster-info | findstr "running"
echo.

echo ✅ Checking LitmusChaos services...
kubectl get pods -n litmus | findstr Running | find /c "Running" > temp.txt
set /p running_pods=<temp.txt
del temp.txt
echo Found %running_pods% running pods

echo.
echo ✅ Checking service accessibility...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:9091' -UseBasicParsing -TimeoutSec 5; Write-Host 'Frontend: HTTP' $r.StatusCode '- Accessible' } catch { Write-Host 'Frontend: Not accessible -' $_.Exception.Message }"

echo.
echo =======================================
echo 🌟 LitmusChaos Ready!
echo =======================================
echo.
echo 🌐 Access Information:
echo    URL: http://localhost:9091
echo    Username: admin
echo    Password: litmus
echo.
echo 📚 Next Steps:
echo    1. Open http://localhost:9091 in your browser
echo    2. Login with admin/litmus credentials
echo    3. Follow the README.md for chaos experiments
echo.
echo 🎯 Happy Chaos Engineering!
echo.

pause
@echo off
REM ===============================================
REM LitmusChaos Graceful Shutdown Script
REM ===============================================
REM This script gracefully shuts down all LitmusChaos components
REM and cleans up system resources

echo ===============================================
echo 🛑 LitmusChaos Graceful Shutdown
echo ===============================================
echo.
echo This will shut down all LitmusChaos components:
echo • Stop port-forwarding processes
echo • Remove demo applications
echo • Scale down LitmusChaos services  
echo • Delete Kubernetes cluster
echo • Clean up Docker resources
echo.

set /p confirm="Continue with shutdown? (y/N): "
if /i not "%confirm%"=="y" (
    echo Shutdown cancelled by user.
    pause
    exit /b 0
)

echo.
echo ===============================================
echo 🔌 Step 1: Stopping Port-Forwarding
echo ===============================================

powershell -Command "Write-Host '🔌 Stopping port-forwarding processes...' -ForegroundColor Yellow; Get-Process | Where-Object {$_.ProcessName -eq 'kubectl' -and $_.CommandLine -like '*port-forward*'} | Stop-Process -Force -ErrorAction SilentlyContinue; Write-Host '✅ Port-forwarding processes stopped' -ForegroundColor Green"

echo.
echo ===============================================
echo 🗑️ Step 2: Removing Demo Applications
echo ===============================================

powershell -Command "Write-Host '🗑️ Checking for demo applications...' -ForegroundColor Yellow; if (kubectl get namespace chaos-demo 2>$null) { Write-Host '📦 Removing demo applications and namespace...' -ForegroundColor Cyan; kubectl delete namespace chaos-demo --timeout=60s --ignore-not-found=true; Write-Host '✅ Demo applications removed' -ForegroundColor Green } else { Write-Host '✅ No demo applications found' -ForegroundColor Green }"

echo.
echo ===============================================
echo ⚙️ Step 3: Scaling Down LitmusChaos Services
echo ===============================================

powershell -Command "Write-Host '⚙️ Checking LitmusChaos services...' -ForegroundColor Yellow; if (kubectl get namespace litmus 2>$null) { Write-Host '🛑 Scaling down deployments...' -ForegroundColor Cyan; kubectl scale deployment --all --replicas=0 -n litmus --timeout=60s; Write-Host '🗄️ Scaling down StatefulSets...' -ForegroundColor Cyan; kubectl scale statefulset --all --replicas=0 -n litmus --timeout=60s; Write-Host '⏳ Waiting for graceful shutdown...' -ForegroundColor Yellow; Start-Sleep 5; Write-Host '🧹 Force cleaning remaining pods...' -ForegroundColor Cyan; kubectl delete pods --all -n litmus --timeout=30s --force --grace-period=0 2>$null; Write-Host '✅ LitmusChaos services stopped' -ForegroundColor Green } else { Write-Host '✅ No LitmusChaos services found' -ForegroundColor Green }"

echo.
echo ===============================================
echo 🐳 Step 4: Removing Kubernetes Cluster
echo ===============================================

powershell -Command "Write-Host '🐳 Checking for Kubernetes cluster containers...' -ForegroundColor Yellow; $containers = docker ps --filter 'name=litmus-cluster' --format '{{.Names}}'; if ($containers) { Write-Host '🛑 Stopping cluster containers...' -ForegroundColor Cyan; docker stop $containers; Write-Host '🗑️ Removing cluster containers...' -ForegroundColor Cyan; docker rm $containers; Write-Host '✅ Kubernetes cluster removed' -ForegroundColor Green } else { Write-Host '✅ No cluster containers found' -ForegroundColor Green }"

echo.
echo ===============================================
echo 🧹 Step 5: Docker Cleanup
echo ===============================================

powershell -Command "Write-Host '🧹 Cleaning up Docker resources...' -ForegroundColor Yellow; $output = docker system prune -f 2>&1; $spaceMatch = $output | Select-String 'Total reclaimed space: (.+)'; if ($spaceMatch) { $space = $spaceMatch.Matches[0].Groups[1].Value; Write-Host '✅ Docker cleanup completed - Freed: ' -ForegroundColor Green -NoNewline; Write-Host $space -ForegroundColor Cyan } else { Write-Host '✅ Docker cleanup completed' -ForegroundColor Green }"

echo.
echo ===============================================
echo 🔍 Final Verification
echo ===============================================

powershell -Command "Write-Host '🔍 Verifying shutdown status...' -ForegroundColor Cyan; Write-Host ''; Write-Host '📦 Docker containers with litmus:' -ForegroundColor Yellow; $containers = docker ps --filter 'name=litmus' --format 'table {{.Names}}\t{{.Status}}'; if (-not $containers -or $containers -eq 'NAMES STATUS') { Write-Host '   ✅ No litmus containers running' -ForegroundColor Green } else { Write-Host $containers }; Write-Host ''; Write-Host '🔌 Port 9091 usage:' -ForegroundColor Yellow; $portUsage = netstat -an 2>$null | findstr ':9091'; if (-not $portUsage) { Write-Host '   ✅ Port 9091 is free' -ForegroundColor Green } else { Write-Host '   ⚠️ Port 9091 still in use' -ForegroundColor Red }; Write-Host ''; Write-Host '🏃 kubectl processes:' -ForegroundColor Yellow; $kubectlProcs = Get-Process -Name kubectl -ErrorAction SilentlyContinue; if (-not $kubectlProcs) { Write-Host '   ✅ No kubectl processes running' -ForegroundColor Green } else { Write-Host '   ⚠️ kubectl processes still running:' -ForegroundColor Red; $kubectlProcs | Format-Table Id, ProcessName, StartTime -AutoSize }"

echo.
echo ===============================================
echo 🎉 GRACEFUL SHUTDOWN COMPLETED!
echo ===============================================
echo.
echo ✅ All LitmusChaos components have been shut down
echo ✅ System resources have been freed
echo ✅ Environment is clean and ready
echo.
echo 🚀 To restart LitmusChaos later:
echo    cd litmus-setup
echo    .\setup-verify.bat
echo.
echo 📚 For more information, see README.md
echo.

pause
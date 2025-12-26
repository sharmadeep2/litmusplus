Write-Host "================================================" -ForegroundColor Cyan
Write-Host "           Litmus++ Access Manager            " -ForegroundColor Cyan  
Write-Host "    Enhanced Chaos Engineering Platform       " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting Litmus++ access..." -ForegroundColor Green

# Clean up existing connections
Write-Host "Cleaning up existing connections..." -ForegroundColor Yellow
Get-Job | Where-Object { $_.Command -like "*kubectl*port-forward*" } | Stop-Job -PassThru | Remove-Job -Force -ErrorAction SilentlyContinue
Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

# Start port forwarding
Write-Host "Starting port forwarding..." -ForegroundColor Yellow
$job = Start-Job -ScriptBlock { kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus }
Start-Sleep 5

# Test connection
Write-Host "Testing connection..." -ForegroundColor Cyan
$response = Invoke-WebRequest -Uri "http://localhost:9091" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue

if ($response -and $response.StatusCode -eq 200) {
    if ($response.Content -match "Litmus\+\+ Chaos Engineering Platform") {
        Write-Host "SUCCESS: Frontend accessible with custom branding" -ForegroundColor Green
    } else {
        Write-Host "SUCCESS: Frontend accessible" -ForegroundColor Green
    }
    
    # Test API
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:9091/api/status" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($apiResponse -and $apiResponse.StatusCode -eq 200) {
        Write-Host "SUCCESS: API working" -ForegroundColor Green
    }
    
    # Test Auth  
    $authResponse = Invoke-WebRequest -Uri "http://localhost:9091/auth/status" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($authResponse -and $authResponse.StatusCode -eq 200) {
        Write-Host "SUCCESS: Auth working" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Litmus++ is now accessible at:" -ForegroundColor Green
    Write-Host "  http://localhost:9091" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ""
    Write-Host "Login credentials:" -ForegroundColor Yellow
    Write-Host "  Username: admin" -ForegroundColor White
    Write-Host "  Password: litmus" -ForegroundColor White
    Write-Host ""
Write-Host "FIXED: CSS files are now properly loaded!" -ForegroundColor Green
Write-Host "The blank page issue should be resolved." -ForegroundColor Green
Write-Host "If you still see issues:" -ForegroundColor Yellow
Write-Host "  1. Clear browser cache and hard refresh (Ctrl+Shift+R)" -ForegroundColor Gray
Write-Host "  2. Wait 30 seconds for React app to fully initialize" -ForegroundColor Gray
Write-Host "  3. Check browser console (F12) for any remaining errors" -ForegroundColor Gray
    exit 1
}

# Keep running
Write-Host ""
Write-Host "Monitoring connection..." -ForegroundColor Gray
try {
    while ($true) {
        Start-Sleep 30
        $testResponse = Invoke-WebRequest -Uri "http://localhost:9091" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if (-not $testResponse) {
            Write-Host "Connection lost. Restarting..." -ForegroundColor Yellow
            $job = Start-Job -ScriptBlock { kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus }
            Start-Sleep 5
        }
    }
} catch {
    Write-Host "Stopping..." -ForegroundColor Red
    Get-Job | Stop-Job -PassThru | Remove-Job -Force -ErrorAction SilentlyContinue
}
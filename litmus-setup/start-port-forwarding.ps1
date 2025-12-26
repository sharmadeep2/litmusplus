#!/usr/bin/env powershell

# Litmus++ Port Forwarding Script
Write-Host "Starting Litmus++ Port Forwarding..." -ForegroundColor Green

# Stop any existing kubectl processes
Write-Host "Stopping existing port forwarding..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start port forwarding for frontend
Write-Host "Starting frontend port forwarding (9091)..." -ForegroundColor Cyan
Start-Process -WindowStyle Hidden kubectl -ArgumentList "port-forward", "svc/chaos-litmus-frontend-service", "9091:9091", "-n", "litmus"

# Start port forwarding for server
Write-Host "Starting server port forwarding (9002)..." -ForegroundColor Cyan
Start-Process -WindowStyle Hidden kubectl -ArgumentList "port-forward", "svc/chaos-litmus-server-service", "9002:9002", "-n", "litmus"

# Start port forwarding for auth server
Write-Host "Starting auth server port forwarding (9003)..." -ForegroundColor Cyan
Start-Process -WindowStyle Hidden kubectl -ArgumentList "port-forward", "svc/chaos-litmus-auth-server-service", "9003:9003", "-n", "litmus"

# Wait a moment for services to start
Start-Sleep -Seconds 5

Write-Host "`nChecking port forwarding status..." -ForegroundColor Yellow
netstat -ano | findstr "909[123]"

Write-Host "`nLitmus++ is now accessible at:" -ForegroundColor Green
Write-Host "Frontend: http://localhost:9091" -ForegroundColor White
Write-Host "Login: admin / litmus" -ForegroundColor Gray

Write-Host "`nPress Ctrl+C to stop all port forwarding..." -ForegroundColor Yellow
try {
    while ($true) {
        Start-Sleep -Seconds 10
        # Check if all processes are still running
        $running = Get-Process kubectl -ErrorAction SilentlyContinue
        if ($running.Count -lt 3) {
            Write-Host "Some port forwarding processes stopped. Restarting..." -ForegroundColor Red
            & $MyInvocation.MyCommand.Path
            break
        }
    }
} catch {
    Write-Host "Stopping port forwarding..." -ForegroundColor Red
    Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force
}
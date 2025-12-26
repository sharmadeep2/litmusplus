#!/usr/bin/env powershell

# Test Litmus++ Frontend Accessibility
Write-Host "Testing Litmus++ Frontend..." -ForegroundColor Green

# Test frontend HTML
Write-Host "`n1. Testing main page HTML..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9091" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Frontend accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    
    # Check if it contains our custom title
    if ($response.Content -match "Litmus\+\+ Chaos Engineering Platform") {
        Write-Host "✓ Custom branding detected" -ForegroundColor Green
    }
}
catch {
    Write-Host "✗ Frontend not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test JavaScript file
Write-Host "`n2. Testing main JavaScript file..." -ForegroundColor Cyan
try {
    $jsResponse = Invoke-WebRequest -Uri "http://localhost:9091/main.aff05d.js" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ JavaScript file accessible (Size: $($jsResponse.Content.Length) bytes)" -ForegroundColor Green
}
catch {
    Write-Host "✗ JavaScript file not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test API endpoints that might be needed
Write-Host "`n3. Testing API endpoints..." -ForegroundColor Cyan
$endpoints = @{
    "http://localhost:9002" = "Main Server"
    "http://localhost:9003" = "Auth Server"
}

foreach ($endpoint in $endpoints.GetEnumerator()) {
    try {
        $apiResponse = Invoke-WebRequest -Uri $endpoint.Key -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✓ $($endpoint.Value) accessible at $($endpoint.Key)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ $($endpoint.Value) not accessible at $($endpoint.Key): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check port forwarding processes
Write-Host "`n4. Checking port forwarding processes..." -ForegroundColor Cyan
$kubectlProcesses = Get-Process kubectl -ErrorAction SilentlyContinue
Write-Host "Active kubectl processes: $($kubectlProcesses.Count)" -ForegroundColor Yellow

# Check listening ports
Write-Host "`n5. Checking listening ports..." -ForegroundColor Cyan
$listeningPorts = netstat -ano | Select-String "LISTENING" | Select-String "909[123]"
$listeningPorts | ForEach-Object { Write-Host $_.Line -ForegroundColor Gray }

Write-Host "`nTest completed!" -ForegroundColor Green
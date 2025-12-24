Write-Host "Testing LitmusChaos Authentication..." -ForegroundColor Cyan
Write-Host "=================================="
Write-Host

$baseUrl = "http://localhost:9091"
$authUrl = "$baseUrl/auth/login"

$credentials = @(
    @{username="admin"; password="admin"},
    @{username="admin"; password="litmus"},
    @{username="admin"; password="password"},
    @{username="litmus"; password="litmus"},
    @{username="admin"; password="Admin123"},
    @{username="admin"; password=""}
)

Write-Host "Testing credential combinations..." -ForegroundColor Yellow
Write-Host

foreach ($cred in $credentials) {
    $username = $cred.username
    $password = $cred.password
    
    Write-Host "Testing: $username / $password"
    
    try {
        $body = @{
            username = $username
            password = $password
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri $authUrl -Method POST -ContentType "application/json" -Body $body -TimeoutSec 10 -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "SUCCESS! Username: $username, Password: $password" -ForegroundColor Green
            Write-Host "Use these credentials to login!" -ForegroundColor Green
            break
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Failed - HTTP $statusCode" -ForegroundColor Red
    }
    Write-Host
}

Write-Host
Write-Host "Access URL: http://localhost:9091" -ForegroundColor Cyan
# Litmus++ Branding Verification Script
# This script verifies that all Litmus++ branding changes are properly applied

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🔍 Litmus++ Branding Verification" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

$VerificationPassed = $true

# Test 1: Check if custom image is deployed
Write-Host "Test 1: Checking custom frontend image deployment..." -ForegroundColor Yellow
try {
    $PodImage = kubectl get pods -n litmus -o jsonpath="{.items[?(@.metadata.labels.app\.kubernetes\.io/component=='litmus-frontend')].spec.containers[0].image}"
    if ($PodImage -like "*litmusplus/frontend:3.24.0-plus*") {
        Write-Host "✅ Custom Litmus++ image is deployed: $PodImage" -ForegroundColor Green
    } else {
        Write-Host "❌ Standard image detected: $PodImage" -ForegroundColor Red
        Write-Host "   Expected: litmusplus/frontend:3.24.0-plus" -ForegroundColor Yellow
        $VerificationPassed = $false
    }
}
catch {
    Write-Host "❌ Failed to check pod image" -ForegroundColor Red
    $VerificationPassed = $false
}

Write-Host ""

# Test 2: Check page title via port-forward
Write-Host "Test 2: Checking page title (requires port-forward)..." -ForegroundColor Yellow
try {
    # Check if port 9091 is accessible
    $Response = Invoke-WebRequest -Uri "http://localhost:9091" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($Response.Content -match '<title>Litmus\+\+ Chaos Engineering Platform</title>') {
        Write-Host "✅ Page title correctly shows 'Litmus++ Chaos Engineering Platform'" -ForegroundColor Green
    } elseif ($Response.Content -match '<title>LitmusChaos</title>') {
        Write-Host "❌ Page still shows original 'LitmusChaos' title" -ForegroundColor Red
        Write-Host "   This may indicate the custom frontend is not active" -ForegroundColor Yellow
        $VerificationPassed = $false
    } else {
        Write-Host "⚠️  Unknown page title detected" -ForegroundColor Orange
        Write-Host "   Response: $($Response.Content.Substring(0, 200))..." -ForegroundColor Gray
    }
}
catch [System.Net.WebException] {
    Write-Host "⚠️  Port 9091 not accessible. Please start port-forwarding:" -ForegroundColor Orange
    Write-Host "   kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus" -ForegroundColor White
}
catch {
    Write-Host "❌ Failed to check page title: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Check custom headers
Write-Host "Test 3: Checking custom HTTP headers..." -ForegroundColor Yellow
try {
    $HealthResponse = Invoke-WebRequest -Uri "http://localhost:9091/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $PoweredByHeader = $HealthResponse.Headers["X-Powered-By"]
    
    if ($PoweredByHeader -like "*Litmus++ Chaos Engineering Platform*") {
        Write-Host "✅ Custom header found: X-Powered-By = $PoweredByHeader" -ForegroundColor Green
    } else {
        Write-Host "❌ Custom header not found or incorrect" -ForegroundColor Red
        Write-Host "   Expected: X-Powered-By = Litmus++ Chaos Engineering Platform" -ForegroundColor Yellow
        if ($PoweredByHeader) {
            Write-Host "   Actual: X-Powered-By = $PoweredByHeader" -ForegroundColor Gray
        }
        $VerificationPassed = $false
    }
}
catch {
    Write-Host "⚠️  Could not check custom headers (port forwarding required)" -ForegroundColor Orange
}

Write-Host ""

# Test 4: Check pod labels and annotations
Write-Host "Test 4: Checking custom labels and annotations..." -ForegroundColor Yellow
try {
    $PodLabels = kubectl get pods -n litmus -l app.kubernetes.io/component=litmus-frontend -o json | ConvertFrom-Json
    $HasCustomLabel = $false
    
    if ($PodLabels.items.Count -gt 0) {
        $Labels = $PodLabels.items[0].metadata.labels
        if ($Labels.'app.kubernetes.io/brand' -eq 'litmus-plus') {
            Write-Host "✅ Custom branding label found: app.kubernetes.io/brand = litmus-plus" -ForegroundColor Green
            $HasCustomLabel = $true
        }
        
        if ($Labels.platform -eq 'enhanced-chaos-engineering') {
            Write-Host "✅ Platform label found: platform = enhanced-chaos-engineering" -ForegroundColor Green
            $HasCustomLabel = $true
        }
    }
    
    if (-not $HasCustomLabel) {
        Write-Host "⚠️  Custom labels not found. This may be normal if not yet applied." -ForegroundColor Orange
    }
}
catch {
    Write-Host "❌ Failed to check pod labels" -ForegroundColor Red
}

Write-Host ""

# Test 5: Check Helm values
Write-Host "Test 5: Checking Helm deployment values..." -ForegroundColor Yellow
try {
    $HelmValues = helm get values chaos -n litmus -o json | ConvertFrom-Json
    
    if ($HelmValues.portal.frontend.image.repository -eq 'litmusplus/frontend' -and 
        $HelmValues.portal.frontend.image.tag -eq '3.24.0-plus') {
        Write-Host "✅ Helm values correctly configured for custom image" -ForegroundColor Green
    } else {
        Write-Host "❌ Helm values not updated for custom image" -ForegroundColor Red
        Write-Host "   Current repository: $($HelmValues.portal.frontend.image.repository)" -ForegroundColor Gray
        Write-Host "   Current tag: $($HelmValues.portal.frontend.image.tag)" -ForegroundColor Gray
        $VerificationPassed = $false
    }
}
catch {
    Write-Host "⚠️  Could not retrieve Helm values" -ForegroundColor Orange
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan

if ($VerificationPassed) {
    Write-Host "🎉 All Litmus++ Branding Verification Tests Passed!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Your Litmus++ Enhanced Platform is properly configured!" -ForegroundColor Green
    Write-Host "🌐 Access at: http://localhost:9091" -ForegroundColor Blue
    Write-Host "🎯 Platform: Litmus++ Enhanced Chaos Engineering" -ForegroundColor Blue
} else {
    Write-Host "⚠️  Some Litmus++ Branding Issues Detected" -ForegroundColor Orange
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Troubleshooting Steps:" -ForegroundColor Yellow
    Write-Host "1. Ensure custom image was built: docker images | findstr litmusplus" -ForegroundColor White
    Write-Host "2. Verify Helm upgrade was successful: helm status chaos -n litmus" -ForegroundColor White
    Write-Host "3. Check pod status: kubectl get pods -n litmus" -ForegroundColor White
    Write-Host "4. Start port forwarding: kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to continue"
# Litmus++ Deployment Update Script
# This script updates the running LitmusChaos deployment to use Litmus++ branding

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🚀 Updating to Litmus++ Enhanced Platform" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Check if custom image exists
Write-Host "🔍 Checking for custom Litmus++ image..." -ForegroundColor Yellow
$ImageExists = docker images --format "table {{.Repository}}:{{.Tag}}" | findstr "litmusplus/frontend:3.24.0-plus"

if (-not $ImageExists) {
    Write-Host "❌ Custom image not found. Please build it first:" -ForegroundColor Red
    Write-Host "   Run: .\build-frontend.ps1" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Custom image found!" -ForegroundColor Green

# Check if cluster is running
Write-Host "🔍 Checking Kubernetes cluster..." -ForegroundColor Yellow
try {
    kubectl get nodes | Out-Null
    Write-Host "✅ Cluster is accessible" -ForegroundColor Green
}
catch {
    Write-Host "❌ Cluster not accessible. Please ensure cluster is running." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Navigate to setup directory
Set-Location "$PSScriptRoot\..\litmus-setup"

# Upgrade Helm deployment with custom values
Write-Host "🎯 Upgrading Litmus deployment to Litmus++..." -ForegroundColor Yellow
try {
    helm upgrade chaos litmuschaos/litmus --namespace=litmus --values litmus-values.yaml --wait --timeout=300s
    Write-Host "✅ Helm upgrade completed!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Helm upgrade failed" -ForegroundColor Red
    Write-Host "Please check the error above and try again" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Wait for pods to be ready
Write-Host "⏳ Waiting for Litmus++ pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod --all -n litmus --timeout=300s

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All pods are ready!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some pods may still be starting. Check status manually." -ForegroundColor Orange
}

# Display pod status
Write-Host ""
Write-Host "📊 Current Pod Status:" -ForegroundColor Blue
kubectl get pods -n litmus

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🎉 Litmus++ Update Complete!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Access Information:" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:9091" -ForegroundColor White
Write-Host "   Platform: Litmus++ Enhanced Chaos Engineering" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: litmus" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Start port forwarding:" -ForegroundColor Blue
Write-Host "   kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue"
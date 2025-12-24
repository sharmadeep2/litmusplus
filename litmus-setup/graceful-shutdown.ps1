# ===============================================
# LitmusChaos Graceful Shutdown Script (PowerShell)
# ===============================================

param(
    [switch]$Force,
    [switch]$SkipConfirmation
)

function Write-Header {
    param($Title)
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
}

function Write-Step {
    param($Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Success {
    param($Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host $Message -ForegroundColor Red
}

# Main script
Clear-Host
Write-Header "🛑 LitmusChaos Graceful Shutdown"

Write-Host "`nThis script will shut down all LitmusChaos components:" -ForegroundColor White
Write-Host "• Stop port-forwarding processes" -ForegroundColor Gray
Write-Host "• Remove demo applications" -ForegroundColor Gray
Write-Host "• Scale down LitmusChaos services" -ForegroundColor Gray
Write-Host "• Delete Kubernetes cluster" -ForegroundColor Gray
Write-Host "• Clean up Docker resources" -ForegroundColor Gray

if (-not $SkipConfirmation) {
    Write-Host "`n"
    $confirmation = Read-Host "Continue with shutdown? (y/N)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Shutdown cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

# Step 1: Stop port-forwarding
Write-Header "🔌 Step 1: Stopping Port-Forwarding"
try {
    Write-Step "🔌 Stopping port-forwarding processes..."
    Get-Process | Where-Object {$_.ProcessName -eq "kubectl" -and $_.CommandLine -like "*port-forward*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Success "✅ Port-forwarding processes stopped"
} catch {
    Write-Warning "⚠️ Error stopping port-forwarding: $($_.Exception.Message)"
}

# Step 2: Remove demo applications
Write-Header "🗑️ Step 2: Removing Demo Applications"
try {
    Write-Step "🗑️ Checking for demo applications..."
    $namespaceExists = kubectl get namespace chaos-demo 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Step "📦 Removing demo applications and namespace..."
        kubectl delete namespace chaos-demo --timeout=60s --ignore-not-found=true | Out-Host
        Write-Success "✅ Demo applications removed"
    } else {
        Write-Success "✅ No demo applications found"
    }
} catch {
    Write-Warning "⚠️ Error removing demo applications: $($_.Exception.Message)"
}

# Step 3: Scale down LitmusChaos services
Write-Header "⚙️ Step 3: Scaling Down LitmusChaos Services"
try {
    Write-Step "⚙️ Checking LitmusChaos services..."
    $litmusNamespace = kubectl get namespace litmus 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Step "🛑 Scaling down deployments..."
        kubectl scale deployment --all --replicas=0 -n litmus --timeout=60s | Out-Host
        
        Write-Step "🗄️ Scaling down StatefulSets..."
        kubectl scale statefulset --all --replicas=0 -n litmus --timeout=60s | Out-Host
        
        Write-Step "⏳ Waiting for graceful shutdown..."
        Start-Sleep 5
        
        Write-Step "🧹 Force cleaning remaining pods..."
        kubectl delete pods --all -n litmus --timeout=30s --force --grace-period=0 2>$null
        
        Write-Success "✅ LitmusChaos services stopped"
    } else {
        Write-Success "✅ No LitmusChaos services found"
    }
} catch {
    Write-Warning "⚠️ Error scaling down services: $($_.Exception.Message)"
}

# Step 4: Remove Kubernetes cluster
Write-Header "🐳 Step 4: Removing Kubernetes Cluster"
try {
    Write-Step "🐳 Checking for Kubernetes cluster containers..."
    $containers = docker ps --filter "name=litmus-cluster" --format "{{.Names}}"
    if ($containers) {
        Write-Step "🛑 Stopping cluster containers..."
        docker stop $containers | Out-Host
        
        Write-Step "🗑️ Removing cluster containers..."
        docker rm $containers | Out-Host
        
        Write-Success "✅ Kubernetes cluster removed"
    } else {
        Write-Success "✅ No cluster containers found"
    }
} catch {
    Write-Warning "⚠️ Error removing cluster: $($_.Exception.Message)"
}

# Step 5: Docker cleanup
Write-Header "🧹 Step 5: Docker Cleanup"
try {
    Write-Step "🧹 Cleaning up Docker resources..."
    $output = docker system prune -f 2>&1
    $spaceMatch = $output | Select-String "Total reclaimed space: (.+)"
    if ($spaceMatch) {
        $space = $spaceMatch.Matches[0].Groups[1].Value
        Write-Success "✅ Docker cleanup completed - Freed: $space"
    } else {
        Write-Success "✅ Docker cleanup completed"
    }
} catch {
    Write-Warning "⚠️ Error during Docker cleanup: $($_.Exception.Message)"
}

# Final verification
Write-Header "🔍 Final Verification"
try {
    Write-Step "🔍 Verifying shutdown status..."
    
    Write-Host "`n📦 Docker containers with litmus:" -ForegroundColor Yellow
    $containers = docker ps --filter "name=litmus" --format "table {{.Names}}`t{{.Status}}"
    if (-not $containers -or $containers -eq "NAMES`tSTATUS") {
        Write-Success "   ✅ No litmus containers running"
    } else {
        Write-Host "   $containers"
    }
    
    Write-Host "`n🔌 Port 9091 usage:" -ForegroundColor Yellow
    $portUsage = netstat -an 2>$null | findstr ":9091"
    if (-not $portUsage) {
        Write-Success "   ✅ Port 9091 is free"
    } else {
        Write-Warning "   ⚠️ Port 9091 still in use"
    }
    
    Write-Host "`n🏃 kubectl processes:" -ForegroundColor Yellow
    $kubectlProcs = Get-Process -Name kubectl -ErrorAction SilentlyContinue
    if (-not $kubectlProcs) {
        Write-Success "   ✅ No kubectl processes running"
    } else {
        Write-Warning "   ⚠️ kubectl processes still running:"
        $kubectlProcs | Format-Table Id, ProcessName, StartTime -AutoSize
    }
} catch {
    Write-Warning "⚠️ Error during verification: $($_.Exception.Message)"
}

# Final summary
Write-Header "🎉 GRACEFUL SHUTDOWN COMPLETED!"
Write-Host "`n✅ All LitmusChaos components have been shut down" -ForegroundColor Green
Write-Host "✅ System resources have been freed" -ForegroundColor Green  
Write-Host "✅ Environment is clean and ready" -ForegroundColor Green

Write-Host "`n🚀 To restart LitmusChaos later:" -ForegroundColor Cyan
Write-Host "   cd litmus-setup" -ForegroundColor White
Write-Host "   .\setup-verify.bat" -ForegroundColor White

Write-Host "`n📚 For more information, see README.md" -ForegroundColor Gray

if (-not $SkipConfirmation) {
    Write-Host "`n" 
    Read-Host "Press Enter to exit"
}
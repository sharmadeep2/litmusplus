# LitmusPlus - Local LitmusChaos Setup

This repository contains a complete local setup for LitmusChaos, an open-source Chaos Engineering platform.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop (running)
- Windows 10/11 with PowerShell
- kubectl (usually comes with Docker Desktop)
- kind (Kubernetes in Docker)
- Helm

### Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/sharmadeep2/litmusplus.git
   cd litmusplus
   ```

2. **Option A - Automated Setup** (verification only):
   ```powershell
   cd litmus-setup
   .\setup-verify.bat
   ```

3. **Option B - Manual Complete Setup** (from scratch):
   Follow the [Manual Setup Instructions](#-manual-setup-instructions) below.

4. Access LitmusChaos:
   - URL: http://localhost:9091
   - Username: `admin`
   - Password: `litmus`

## 🔧 Manual Setup Instructions

### Step 1: Verify Prerequisites

1. **Check Docker Desktop is running**:
   ```powershell
   docker version
   ```
   Should show both Client and Server versions.

2. **Install kind (if not already installed)**:
   ```powershell
   # Using Chocolatey
   choco install kind

   # Or download from https://kind.sigs.k8s.io/docs/user/quick-start/#installation
   ```

3. **Install Helm (if not already installed)**:
   ```powershell
   # Using Chocolatey
   choco install kubernetes-helm

   # Or download from https://helm.sh/docs/intro/install/
   ```

### Step 2: Create Kubernetes Cluster

```powershell
# Navigate to setup directory
cd litmus-setup

# Create Kind cluster using provided configuration
kind create cluster --config=kind-config.yaml

# Verify cluster is running
kubectl get nodes
```

Expected output: 3 nodes (1 control-plane, 2 workers) in Ready status.

### Step 3: Install LitmusChaos

```powershell
# Create namespace for Litmus
kubectl create namespace litmus

# Add LitmusChaos Helm repository
helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm

# Update Helm repositories
helm repo update

# Install LitmusChaos using custom values
helm install chaos litmuschaos/litmus --namespace=litmus --values litmus-values.yaml
```

### Step 4: Wait for Services to Start

```powershell
# Wait for all pods to be ready (this may take 2-5 minutes)
kubectl wait --for=condition=ready pod --all -n litmus --timeout=300s

# Verify all pods are running
kubectl get pods -n litmus
```

Expected output: All pods should show `1/1 Running` status.

### Step 5: Start Port Forwarding and Access UI

```powershell
# Start port forwarding to access the UI (keep this terminal open)
kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
```

**Important**: Keep this terminal window open. Port forwarding must remain active to access the UI.

### Step 6: Access LitmusChaos

1. Open your web browser
2. Navigate to: **http://localhost:9091**
3. Login with:
   - **Username**: `admin`
   - **Password**: `litmus`

## 📁 Repository Structure

```
litmusplus/
├── README.md                    # This file
└── litmus-setup/               # LitmusChaos setup files
    ├── kind-config.yaml        # Kubernetes cluster configuration
    ├── litmus-values.yaml      # Helm chart values for Litmus
    ├── setup-verify.bat        # Windows setup verification script
    ├── setup-verify.sh         # Linux/Mac setup verification script
    ├── start-litmus.bat        # Start LitmusChaos services (Windows)
    ├── final-verify.bat        # Complete setup verification
    ├── graceful-shutdown.bat   # Graceful shutdown script (Windows)
    ├── graceful-shutdown.ps1   # Graceful shutdown script (PowerShell)
    ├── admin-setup.bat         # Authentication troubleshooting
    ├── test-auth-simple.ps1    # Test authentication credentials
    └── create-admin.sh         # Manual admin user creation script
```

## 🛠️ What Gets Installed

- **Kind** - Kubernetes in Docker (3-node cluster)
- **Helm** - Package manager for Kubernetes
- **LitmusChaos** - Complete chaos engineering platform
- **MongoDB** - Database backend for Litmus

## 🔧 Management Commands

### Cluster Management
```powershell
# Start port forwarding to access Litmus UI
kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus

# Check cluster status
kubectl get nodes

# Check Litmus pods
kubectl get pods -n litmus

# Check services
kubectl get services -n litmus
```

### Litmus Management
```powershell
# Scale down Litmus (stop)
kubectl scale deployment --all --replicas=0 -n litmus

# Scale up Litmus (start)
kubectl scale deployment --all --replicas=1 -n litmus

# View logs
kubectl logs -l app=chaos-litmus-frontend -n litmus

# Uninstall Litmus
helm uninstall chaos -n litmus

# Delete entire cluster
kind delete cluster --name litmus-cluster
```

## 🛑 Graceful Shutdown

### 🚀 Method 1: One-Click Shutdown (Recommended)

```powershell
# Navigate to setup directory
cd litmus-setup

# Run graceful shutdown (Windows)
.\graceful-shutdown.bat

# OR using PowerShell
.\graceful-shutdown.ps1
```

This script will:
- ✅ Stop all port-forwarding processes
- ✅ Remove demo applications (nginx, etc.)
- ✅ Scale down all LitmusChaos services gracefully
- ✅ Delete Kubernetes cluster and containers
- ✅ Clean up Docker resources and free disk space
- ✅ Verify complete shutdown

### 🔧 Method 2: Manual Shutdown Steps

```powershell
# Step 1: Stop port forwarding
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force

# Step 2: Remove demo applications
kubectl delete namespace chaos-demo --timeout=60s

# Step 3: Scale down LitmusChaos
kubectl scale deployment --all --replicas=0 -n litmus
kubectl scale statefulset --all --replicas=0 -n litmus
kubectl delete pods --all -n litmus --force

# Step 4: Remove cluster
docker stop litmus-cluster-control-plane litmus-cluster-worker litmus-cluster-worker2
docker rm litmus-cluster-control-plane litmus-cluster-worker litmus-cluster-worker2

# Step 5: Clean Docker resources
docker system prune -f
```

### 🆘 PowerShell Advanced Options

```powershell
# Silent shutdown (no confirmations)
.\graceful-shutdown.ps1 -SkipConfirmation

# Force shutdown (ignore errors)
.\graceful-shutdown.ps1 -Force

# Combined options
.\graceful-shutdown.ps1 -SkipConfirmation -Force
```

### 📋 Shutdown Verification

After running the shutdown script, verify:

- [ ] No Docker containers with "litmus" in name
- [ ] Port 9091 is free (not in use)
- [ ] No kubectl processes running
- [ ] Docker space has been reclaimed
- [ ] System resources freed

---

## ⚡ Starting Applications - Complete Guide

### 🚀 Method 1: Quick Restart (if cluster already exists)

```powershell
# Navigate to setup directory
cd litmus-setup

# Check if cluster exists
kind get clusters

# If cluster exists, verify it's running
kubectl get pods -n litmus

# Start port forwarding to access UI
kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
```

### 🔧 Method 2: Complete Setup from Scratch

If you need to start from scratch or the cluster doesn't exist:

```powershell
# Step 1: Navigate to setup directory
cd litmus-setup

# Step 2: Create Kubernetes cluster
kind create cluster --config=kind-config.yaml

# Step 3: Wait for nodes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# Step 4: Create namespace and install LitmusChaos
kubectl create namespace litmus
helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm
helm repo update
helm install chaos litmuschaos/litmus --namespace=litmus --values litmus-values.yaml

# Step 5: Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all -n litmus --timeout=300s

# Step 6: Start port forwarding
kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
```

### 🆘 Troubleshooting Startup Issues

#### No Cluster Found:
```powershell
# Check if cluster exists
kind get clusters

# If no clusters, create one
kind create cluster --config=kind-config.yaml
```

#### Cluster Not Responding:
```powershell
# Check cluster status
kubectl cluster-info

# If failed, restart cluster
kind delete cluster --name litmus-cluster
kind create cluster --config=kind-config.yaml
```

#### LitmusChaos Not Installed:
```powershell
# Check if namespace exists
kubectl get namespace litmus

# If not found, install LitmusChaos
kubectl create namespace litmus
helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm
helm repo update
helm install chaos litmuschaos/litmus --namespace=litmus --values litmus-values.yaml
```

#### Pods Not Ready:
```powershell
# Check pod status
kubectl get pods -n litmus

# If pods are failing, check logs
kubectl logs -l app=chaos-litmus-frontend -n litmus

# Restart deployments if needed
kubectl rollout restart deployment -n litmus
```

#### Service Not Accessible:
```powershell
# Check if port forwarding is running
netstat -an | findstr 9091

# If not running, start port forwarding
kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
```

### 📋 Complete Startup Checklist

- [ ] Docker Desktop is running (`docker version`)
- [ ] Kind cluster exists (`kind get clusters`)
- [ ] Kubernetes cluster is accessible (`kubectl cluster-info`)
- [ ] LitmusChaos namespace exists (`kubectl get namespace litmus`)
- [ ] All LitmusChaos pods are in 'Running' state (`kubectl get pods -n litmus`)
- [ ] Port forwarding is active on port 9091 (`netstat -an | findstr 9091`)
- [ ] LitmusChaos UI accessible at http://localhost:9091
- [ ] Login successful with admin/litmus credentials

### ⏱️ Expected Startup Times
- **Cluster Creation**: 30-60 seconds
- **LitmusChaos Installation**: 2-5 minutes
- **Port Forwarding**: Immediate
- **Total Setup Time**: 3-7 minutes

---

## 🎯 Step-by-Step Application Setup & Chaos Experiments

### Step 1: Initial Setup & Access LitmusChaos

1. **Start the LitmusChaos UI**:
   ```powershell
   # In a new terminal, start port forwarding
   kubectl port-forward svc/chaos-litmus-frontend-service 9091:9091 -n litmus
   ```

2. **Access LitmusChaos Dashboard**:
   - Open browser: http://localhost:9091
   - Username: `admin`
   - Password: `litmus`

3. **Verify Installation**:
   ```powershell
   # Check all pods are running
   kubectl get pods -n litmus
   
   # Should show all pods in 'Running' status
   ```

### Step 2: Deploy a Sample Application

Let's deploy a sample nginx application to run chaos experiments on:

1. **Create a test namespace**:
   ```powershell
   kubectl create namespace chaos-demo
   ```

2. **Deploy sample nginx application**:
   ```powershell
   # Create nginx deployment
   kubectl create deployment nginx-app --image=nginx:latest --replicas=3 -n chaos-demo
   
   # Expose nginx service
   kubectl expose deployment nginx-app --port=80 --type=NodePort -n chaos-demo
   
   # Verify deployment
   kubectl get pods -n chaos-demo
   kubectl get services -n chaos-demo
   ```

3. **Create a sample multi-tier application** (Optional):
   ```powershell
   # Deploy a more complex app with frontend, backend, and database
   kubectl apply -f https://raw.githubusercontent.com/litmuschaos/chaos-charts/master/sample-apps/podtato-head/podtato-head.yaml -n chaos-demo
   ```

### Step 3: Set Up Chaos Infrastructure

1. **Create Environment in LitmusChaos**:
   - Go to **"Environments"** → **"New Environment"**
   - Name: `local-chaos`
   - Environment Type: `Production` or `Non-Production`
   - Click **"Create"**

2. **Configure Chaos Infrastructure**:
   - Click **"Enable Chaos"** on your environment
   - Infrastructure Name: `local-infrastructure`
   - Description: `Local Kubernetes cluster for chaos testing`
   - Platform Name: `local-cluster`
   - Installation Mode: **"Cluster Wide"**
   - Namespace: `litmus`
   - Service Account: `litmus`
   - Click **"Next"**

3. **Deploy Chaos Infrastructure**:
   ```powershell
   # Download and apply the generated YAML
   # (Copy the YAML from LitmusChaos UI)
   kubectl apply -f local-infrastructure-manifest.yml
   
   # Verify chaos infrastructure
   kubectl get pods -n litmus | grep chaos
   ```

### Step 4: Create Your First Chaos Experiment

#### Option A: Using LitmusChaos Web UI

1. **Access Chaos Experiments**:
   - Go to **"Chaos Experiments"** → **"Schedule a Chaos Experiment"**
   - Choose **"Create New Experiment"**

2. **Configure Experiment**:
   - Experiment Name: `nginx-pod-delete-test`
   - Description: `Delete nginx pods to test resilience`
   - Choose Infrastructure: `local-infrastructure`

3. **Add Chaos Fault**:
   - Click **"Add"** → **"Add new fault"**
   - Select **"Generic"** → **"Pod Delete"**
   - Configure fault:
     - Target Pods: `nginx-app`
     - Namespace: `chaos-demo`
     - Duration: `30s`

4. **Set Experiment Schedule**:
   - Choose **"Run Now"** or set a schedule
   - Click **"Finish & Run"**

#### Option B: Using kubectl (YAML method)

1. **Create chaos experiment YAML**:
   ```powershell
   # Create pod-delete experiment file
   @"
   apiVersion: litmuschaos.io/v1alpha1
   kind: ChaosEngine
   metadata:
     name: nginx-pod-delete
     namespace: chaos-demo
   spec:
     appinfo:
       appns: chaos-demo
       applabel: 'app=nginx-app'
       appkind: 'deployment'
     chaosServiceAccount: litmus-admin
     experiments:
     - name: pod-delete
       spec:
         components:
           env:
           - name: TOTAL_CHAOS_DURATION
             value: '30'
           - name: CHAOS_INTERVAL
             value: '10'
           - name: FORCE
             value: 'false'
   "@ > nginx-chaos.yaml
   ```

2. **Apply the experiment**:
   ```powershell
   kubectl apply -f nginx-chaos.yaml
   ```

3. **Monitor the experiment**:
   ```powershell
   # Watch pods during chaos
   kubectl get pods -n chaos-demo -w
   
   # Check experiment status
   kubectl describe chaosengine nginx-pod-delete -n chaos-demo
   
   # View experiment logs
   kubectl logs -l name=pod-delete -n chaos-demo
   ```

### Step 5: Monitor and Analyze Results

1. **View Experiment Results in UI**:
   - Go to **"Chaos Experiments"** → **"Browse Experiments"**
   - Click on your experiment to view detailed results
   - Check resilience score and experiment timeline

2. **Command Line Monitoring**:
   ```powershell
   # Check experiment results
   kubectl get chaosresult -n chaos-demo
   
   # Detailed result
   kubectl describe chaosresult nginx-pod-delete-pod-delete -n chaos-demo
   
   # Application recovery status
   kubectl get pods -n chaos-demo
   ```

### Step 6: Advanced Experiments

#### CPU Stress Test
```powershell
# Create CPU stress experiment
@"
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: nginx-cpu-stress
  namespace: chaos-demo
spec:
  appinfo:
    appns: chaos-demo
    applabel: 'app=nginx-app'
    appkind: 'deployment'
  chaosServiceAccount: litmus-admin
  experiments:
  - name: pod-cpu-hog
    spec:
      components:
        env:
        - name: TOTAL_CHAOS_DURATION
          value: '60'
        - name: CPU_CORES
          value: '1'
        - name: PODS_AFFECTED_PERC
          value: '50'
"@ > cpu-stress-chaos.yaml

kubectl apply -f cpu-stress-chaos.yaml
```

#### Memory Stress Test
```powershell
# Create memory stress experiment
@"
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: nginx-memory-stress
  namespace: chaos-demo
spec:
  appinfo:
    appns: chaos-demo
    applabel: 'app=nginx-app'
    appkind: 'deployment'
  chaosServiceAccount: litmus-admin
  experiments:
  - name: pod-memory-hog
    spec:
      components:
        env:
        - name: TOTAL_CHAOS_DURATION
          value: '60'
        - name: MEMORY_CONSUMPTION
          value: '500'
        - name: PODS_AFFECTED_PERC
          value: '50'
"@ > memory-stress-chaos.yaml

kubectl apply -f memory-stress-chaos.yaml
```

### Step 7: Set Up Monitoring (Optional)

1. **Deploy Prometheus for monitoring**:
   ```powershell
   # Add prometheus helm repo
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   
   # Install prometheus
   kubectl create namespace monitoring
   helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
   
   # Access Prometheus UI
   kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
   # Visit: http://localhost:9090
   ```

2. **Access Grafana Dashboard**:
   ```powershell
   # Port forward Grafana
   kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
   # Visit: http://localhost:3000
   # Username: admin, Password: prom-operator
   ```

### Step 8: Cleanup

1. **Stop experiments**:
   ```powershell
   # Delete chaos engines
   kubectl delete chaosengine --all -n chaos-demo
   ```

2. **Remove test applications**:
   ```powershell
   # Delete demo namespace
   kubectl delete namespace chaos-demo
   ```

3. **Scale down LitmusChaos** (to save resources):
   ```powershell
   kubectl scale deployment --all --replicas=0 -n litmus
   ```

### 📊 Experiment Ideas to Try

1. **Network Chaos**: Test network latency, packet loss
2. **Storage Chaos**: Simulate disk failures
3. **Node Chaos**: Drain, reboot, or stop nodes
4. **Application-specific**: Database connection failures, API timeouts
5. **Multi-fault scenarios**: Combine different chaos types

### 🔍 Troubleshooting

- **Pods not starting**: Check resources with `kubectl describe pod <pod-name> -n litmus`
- **Experiments failing**: Verify RBAC permissions and target application labels
- **UI not accessible**: Ensure port-forward is running and check firewall
- **Chaos not applied**: Check ChaosEngine status and experiment logs

## 📚 Resources

- [LitmusChaos Documentation](https://docs.litmuschaos.io/)
- [Chaos Engineering Principles](https://principlesofchaos.org/)
- [LitmusChaos GitHub](https://github.com/litmuschaos/litmus)
- [Community Slack](https://kubernetes.slack.com/?redir=%2Farchives%2FCNXNB0ZTN)

## 🤝 Contributing

Feel free to contribute improvements to this setup:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This setup is designed for local development and learning. For production deployments, please refer to the official LitmusChaos documentation for proper security and scalability configurations.

---

**Happy Chaos Engineering!** 🎭
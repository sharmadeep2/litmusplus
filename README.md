# LitmusPlus - Local LitmusChaos Setup

This repository contains a complete local setup for LitmusChaos, an open-source Chaos Engineering platform.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- Windows 10/11 with PowerShell

### Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/sharmadeep2/litmusplus.git
   cd litmusplus
   ```

2. Run the setup (automated):
   ```powershell
   cd litmus-setup
   .\setup-verify.bat
   ```

3. Access LitmusChaos:
   - URL: http://localhost:9091
   - Username: `admin`
   - Password: `litmus`

## 📁 Repository Structure

```
litmusplus/
├── README.md                 # This file
└── litmus-setup/            # LitmusChaos setup files
    ├── kind-config.yaml     # Kubernetes cluster configuration
    ├── litmus-values.yaml   # Helm chart values for Litmus
    ├── setup-verify.bat     # Windows setup verification script
    └── setup-verify.sh      # Linux/Mac setup verification script
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
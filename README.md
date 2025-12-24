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

## 🎯 Getting Started with Chaos Engineering

1. **Login** to Litmus at http://localhost:9091
2. **Create an Environment** - Set up your chaos infrastructure
3. **Browse Chaos Hub** - Explore pre-built experiments
4. **Run Your First Experiment** - Try pod deletion or CPU stress
5. **Monitor Results** - Analyze the impact and resilience

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
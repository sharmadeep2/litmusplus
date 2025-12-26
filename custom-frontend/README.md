# Litmus++ Custom Frontend Documentation

This document explains the custom frontend implementation that transforms LitmusChaos into Litmus++ Enhanced Chaos Engineering Platform.

## 📁 Custom Frontend Structure

```
custom-frontend/
├── Dockerfile                 # Custom frontend container image
├── index.html                # Enhanced HTML with Litmus++ branding
├── nginx-custom.conf         # Custom nginx configuration
├── startup-branding.sh       # Branding initialization script
├── build-frontend.ps1        # Windows build script
└── build.sh                 # Linux/Mac build script
```

## 🎯 Branding Changes Implemented

### 1. **HTML Page Title & Meta Tags**
- **Before**: `<title>LitmusChaos</title>`
- **After**: `<title>Litmus++ Chaos Engineering Platform</title>`
- **Added**: Enhanced meta descriptions and Open Graph tags
- **Added**: Application name and branding metadata

### 2. **Custom Headers**
- **X-Powered-By**: "Litmus++ Chaos Engineering Platform"
- **X-Application**: "Litmus++ Enhanced Platform"
- **Custom health check**: Returns "Litmus++ is running"

### 3. **Enhanced Configuration**
- Custom nginx configuration with Litmus++ headers
- Enhanced proxy settings with branded headers
- Improved logging and monitoring capabilities

## 🔧 Build Process

### Automated Build (Windows)
```powershell
# Navigate to project directory
cd custom-frontend

# Run the automated build script
.\build-frontend.ps1
```

### Manual Build
```bash
# Navigate to project directory
cd custom-frontend

# Build the Docker image
docker build -t litmusplus/frontend:3.24.0-plus .

# Verify the image
docker images | grep litmusplus
```

## 🚀 Deployment Process

### Automated Deployment (Windows)
```powershell
# After building the custom frontend
cd ..\litmus-setup

# Run the deployment update script
.\update-litmus-plus.ps1
```

### Manual Deployment
```bash
# Update Helm deployment with custom values
helm upgrade chaos litmuschaos/litmus \
  --namespace=litmus \
  --values litmus-values.yaml \
  --wait --timeout=300s

# Wait for pods to be ready
kubectl wait --for=condition=ready pod --all -n litmus --timeout=300s
```

## 📊 Verification Steps

### 1. Check Custom Image
```bash
kubectl get pods -n litmus -o yaml | grep "image:"
```
Should show: `litmusplus/frontend:3.24.0-plus`

### 2. Verify Page Title
```bash
curl -s http://localhost:9091 | grep "<title>"
```
Should show: `<title>Litmus++ Chaos Engineering Platform</title>`

### 3. Check Custom Headers
```bash
curl -I http://localhost:9091/health
```
Should include: `X-Powered-By: Litmus++ Chaos Engineering Platform`

## 🔄 Customization Options

### Adding Custom Logos
1. Place logo files in `custom-frontend/`
2. Update the Dockerfile to copy them:
   ```dockerfile
   COPY custom-logo.svg /opt/chaos/custom-logo.svg
   ```

### Modifying Text Content
1. Update `index.html` for page metadata
2. For runtime text changes, modify `startup-branding.sh`:
   ```bash
   sed -i 's/LitmusChaos/Litmus++/g' /opt/chaos/*.js
   ```

### Custom Styling
1. Add CSS files to the `custom-frontend/` directory
2. Update the Dockerfile to include them
3. Reference in the modified `index.html`

## 🐛 Troubleshooting

### Image Build Issues
- Ensure Docker Desktop is running
- Check available disk space
- Verify base image accessibility

### Deployment Issues
- Confirm custom image exists: `docker images | grep litmusplus`
- Check Helm values syntax: `helm template chaos litmuschaos/litmus --values litmus-values.yaml`
- Verify cluster connectivity: `kubectl get nodes`

### Pod Not Starting
- Check pod logs: `kubectl logs -n litmus deployment/chaos-litmus-frontend`
- Verify image pull: `kubectl describe pod -n litmus`
- Check resource limits and node capacity

## ⚠️ Important Notes

### Maintenance
- Rebuild custom image when updating LitmusChaos versions
- Keep custom files in sync with base image updates
- Monitor for breaking changes in LitmusChaos releases

### Security
- Custom images should be scanned for vulnerabilities
- Ensure base image security updates are incorporated
- Follow container security best practices

### Performance
- Monitor image size growth with customizations
- Optimize custom assets (compress images, minify CSS/JS)
- Test performance impact of custom modifications

## 📝 License & Attribution

This custom frontend is based on LitmusChaos and maintains compliance with the original Apache 2.0 license. All modifications are clearly documented and attributed.

**Base Software**: LitmusChaos 3.24.0 (Apache 2.0 License)
**Custom Enhancements**: Litmus++ branding and UI improvements
**Maintained by**: Deepak Sharma <sharmadeep@microsoft.com>
# Docker build script for Litmus++ Custom Frontend

# Build the custom frontend image
docker build -t litmusplus/frontend:3.24.0-plus ./custom-frontend

# Tag for local registry (optional)
docker tag litmusplus/frontend:3.24.0-plus localhost:5000/litmusplus/frontend:3.24.0-plus

# If you want to push to a registry, uncomment below:
# docker push your-registry.com/litmusplus/frontend:3.24.0-plus

echo "Custom Litmus++ frontend image built successfully!"
echo "Image: litmusplus/frontend:3.24.0-plus"
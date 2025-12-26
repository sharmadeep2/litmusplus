# Litmus++ Custom Frontend
# Based on LitmusChaos 3.24.0 with enhanced branding

FROM litmuschaos.docker.scarf.sh/litmuschaos/litmusportal-frontend:3.24.0

LABEL maintainer="Deepak Sharma <sharmadeep@microsoft.com>"
LABEL description="Litmus++ Enhanced Chaos Engineering Platform Frontend"
LABEL version="3.24.0-plus"

# Copy custom assets to override defaults
COPY index.html /opt/chaos/index.html
COPY litmus-plus-branding.css /opt/chaos/litmus-plus-branding.css
COPY litmus-plus-branding.js /opt/chaos/litmus-plus-branding.js

# Copy any custom logos/assets
# COPY custom-logo.svg /opt/chaos/custom-logo.svg

EXPOSE 8185

# Use the original nginx entrypoint with custom index.html
CMD ["nginx", "-g", "daemon off;"]
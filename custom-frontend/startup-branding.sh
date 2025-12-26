#!/bin/sh
# Startup script for Litmus++ branding

echo "Starting Litmus++ Chaos Engineering Platform..."

# Perform any runtime branding modifications here
# This script allows for dynamic content replacement if needed

# Replace any runtime text in JavaScript bundles (if necessary)
# Note: This is a placeholder for more advanced text replacement
# sed -i 's/LitmusChaos/Litmus++/g' /opt/chaos/*.js 2>/dev/null || true
# sed -i 's/"Litmus"/"Litmus++"/g' /opt/chaos/*.js 2>/dev/null || true

# Log startup
echo "Litmus++ Frontend initialized at $(date)"
echo "Branding: Enhanced Chaos Engineering Platform"

# Start nginx with original entrypoint
exec nginx -g "daemon off;"
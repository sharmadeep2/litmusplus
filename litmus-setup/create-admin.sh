#!/usr/bin/env bash
# Script to create default admin user for LitmusChaos

echo "Creating admin user for LitmusChaos..."

# First, let's check if we can access the auth API
AUTH_URL="http://localhost:9091"

# Try to check capabilities
echo "Checking authentication service..."

# For LitmusChaos 3.x, try different approaches
echo "Attempting to create default admin user..."

# Method 1: Check if there's a setup endpoint
curl -X POST "$AUTH_URL/auth/create_user" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "litmus",
    "role": "admin",
    "email": "admin@litmus.io"
  }' 2>/dev/null || echo "Method 1 failed"

# Method 2: Try the GraphQL endpoint for user creation
curl -X POST "$AUTH_URL/api/graphql" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { createUser(user: { username: \"admin\", password: \"litmus\", role: \"admin\", email: \"admin@litmus.io\" }) { id username } }"
  }' 2>/dev/null || echo "Method 2 failed"

echo "Admin user creation attempted. Try logging in with admin/litmus"
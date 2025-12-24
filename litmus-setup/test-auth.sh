#!/bin/bash

echo "🔐 Testing LitmusChaos Authentication..."
echo "=================================="
echo

# Test different admin credentials
BASE_URL="http://localhost:9091"
AUTH_URL="$BASE_URL/auth/login"

echo "Testing credential combinations..."
echo

# Common LitmusChaos 3.x combinations
declare -a CREDENTIALS=(
    "admin:admin"
    "admin:litmus" 
    "admin:password"
    "litmus:litmus"
    "admin:Admin123"
    "admin:"
)

for cred in "${CREDENTIALS[@]}"; do
    IFS=':' read -r username password <<< "$cred"
    echo "Testing: $username / $password"
    
    # Test login via API call
    response=$(curl -s -w "%{http_code}" -X POST "$AUTH_URL" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$username\",\"password\":\"$password\"}" \
        -o /dev/null)
    
    if [ "$response" = "200" ]; then
        echo "✅ SUCCESS! Username: $username, Password: $password"
        break
    else
        echo "❌ Failed (HTTP $response)"
    fi
    echo
done

echo
echo "🌐 Access URL: http://localhost:9091"
echo "📖 If all tests fail, check if LitmusChaos 3.x requires initial setup wizard"
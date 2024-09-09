#!/bin/bash

# Start the Next.js app
npm start &

# Allow Next.js app to start up fully
sleep 5

# Function to run wrk tests
run_test() {
    local test_name=$1
    local url=$2
    echo "---"
    echo "Test: $test_name"
    echo ""
    wrk -t12 -c40 -d30s $url
    echo "---"
    echo ""
}

# Function to check service status
check_service() {
    local service_name=$1
    local action=$2
    service $service_name $action
    if [ $? -ne 0 ]; then
        echo "Failed to $action $service_name. Exiting."
        exit 1
    fi
}

# Start Nginx with the baseline configuration and run tests
cp /testing-config/nginx-rate-limit.conf /etc/nginx/nginx.conf
check_service nginx start
run_test "Nginx Baseline - Unprotected" "http://localhost:8080/api/unprotected"
run_test "Arcjet Rate Limiting" "http://localhost:8080/api/rate-limit"
run_test "Arcjet Bot Protection" "http://localhost:8080/api/bot-detect"

# Configure Nginx for rate limiting and restart, then run tests
cp /testing-config/nginx-rate-limit.conf /etc/nginx/nginx.conf
check_service nginx restart
run_test "Nginx Rate Limiting" "http://localhost:8080/api/unprotected"

# Configure Nginx for bot protection and restart, then run tests
cp /testing-config/nginx-bot-protect.conf /etc/nginx/nginx.conf
check_service nginx restart
run_test "Nginx Bot Protection" "http://localhost:8080/api/unprotected"

# Configure for Fail2Ban tests
cp /testing-config/nginx-fail2ban.conf /etc/nginx/nginx.conf
check_service nginx restart
cp /testing-config/fail2ban-nginx-limit.conf /etc/fail2ban/filter.d/nginx-limit.conf
cp /testing-config/fail2ban.jail.local /etc/fail2ban/jail.local
check_service fail2ban start
run_test "Fail2Ban Rate Limiting" "http://localhost:8080/api/unprotected"

# Keep the container running
tail -f /dev/null

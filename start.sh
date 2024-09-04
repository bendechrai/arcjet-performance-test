#!/bin/bash

# Start the Next.js app
npm start &

# Allow Next.js app to start up fully
sleep 5

# Function to run wrk tests
run_test() {
    local test_name=$1
    local url=$2
    echo "Test: $test_name"
    wrk -t12 -c400 -d30s $url
}

# Start Nginx with the baseline configuration and run tests
cp /etc/nginx/conf.d/nginx.conf /etc/nginx/nginx.conf
service nginx start
run_test "Nginx Baseline - Unprotected" "http://localhost:8080/api/unprotected"
run_test "Arcjet Rate Limiting" "http://localhost:8080/api/rate-limit"
run_test "Arcjet Bot Protection" "http://localhost:8080/api/bot-detect"

# Configure Nginx for rate limiting and restart, then run tests
cp /etc/nginx/conf.d/nginx-rate-limit.conf /etc/nginx/nginx.conf
service nginx restart
run_test "Nginx Rate Limiting" "http://localhost:8080/api/unprotected"

# Configure Nginx for bot protection and restart, then run tests
cp /etc/nginx/conf.d/nginx-bot-protect.conf /etc/nginx/nginx.conf
service nginx restart
run_test "Nginx Bot Protection" "http://localhost:8080/api/unprotected"

# Configure for Fail2Ban tests
cp /etc/nginx/conf.d/nginx-fail2ban.conf /etc/nginx/nginx.conf
service nginx restart
service fail2ban start
run_test "Fail2Ban Rate Limiting" "http://localhost:8080/api/unprotected"

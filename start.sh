#!/bin/bash

# Start the Next.js app
npm start &

# Allow Next.js app to start up fully
sleep 2

# Function to run wrk tests
run_test() {
    local test_name=$1
    local url=$2
    echo "---"
    echo "Test: $test_name"
    echo ""
    # wrk -t2 -c2 -d5s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36" $url
    ab -n 100 -c 1 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36" $url
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

# # Start Nginx with the baseline configuration and run tests
# cp /testing-config/nginx-rate-limit.conf /etc/nginx/nginx.conf
# check_service nginx start
# run_test "Nginx Baseline - Unprotected" "http://localhost:8080/api/unprotected?nginx-baseline"

# # Test the Arcjet Rate Limiting against the default Nginx configuration
# run_test "Arcjet Rate Limiting" "http://localhost:8080/api/rate-limit"

# # Wait a few seconds for any block cache to expire
# sleep 2

# # Test the Arcjet Bot Protection against the default Nginx configuration
# run_test "Arcjet Bot Protection" "http://localhost:8080/api/bot-detect"

# # Configure Nginx for rate limiting and restart, then run tests
# cp /testing-config/nginx-rate-limit.conf /etc/nginx/nginx.conf
# check_service nginx restart
# run_test "Nginx Rate Limiting" "http://localhost:8080/api/unprotected?nginx-rate-limit"

# # Configure Nginx for bot protection and restart, then run tests
# cp /testing-config/nginx-bot-protect.conf /etc/nginx/nginx.conf
# check_service nginx restart
# run_test "Nginx Bot Protection" "http://localhost:8080/api/unprotected?nginx-bot-protect"

# Keep the container running
tail -f /dev/null

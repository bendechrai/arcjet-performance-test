#!/bin/bash

UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
UA_CURL="curl/7.88.1"

# Function to run wrk tests
run_test() {
    local test_name=$1
    local url=$2
    local useragent=$3
    echo "---"
    echo "Test: $test_name"
    echo ""
    ab -n 100 -c 1 -H "User-Agent: $useragent" $url
    echo "---"
    echo ""
}

# Function to check service status
check_service() {
    local service_name=$1
    local action=$2
    sudo service $service_name $action
    if [ $? -ne 0 ]; then
        echo "Failed to $action $service_name. Exiting."
        exit 1
    fi
}

# Pre-warm Next.js routes
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:8080/api/unprotected
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:8080/api/rate-limit
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:8080/api/bot-detect

# Configure Nginx for baseline configuration and restart
sudo cp ./config/nginx.conf /etc/nginx/nginx.conf
check_service nginx restart

# Run baseline test against the default Nginx configuration
run_test "Nginx Baseline from Browser" "http://localhost:8080/api/unprotected" $UA_BROWSER

# Run Arcjet Rate Limiting against the default Nginx configuration
run_test "Arcjet Rate Limiting from Browser" "http://localhost:8080/api/rate-limit" $UA_BROWSER

# Run Arcjet Bot Protection against the default Nginx configuration with browser user agent
run_test "Arcjet Bot Protection from Browser" "http://localhost:8080/api/bot-detect" $UA_BROWSER

# Bot Protection has a 60s block cache, so we need to wait for it to expire
sleep 61

# Run Arcjet Bot Protection against the default Nginx configuration with curl user agent
run_test "Arcjet Bot Protection from Curl" "http://localhost:8080/api/bot-detect" $UA_CURL

# Configure Nginx for rate limiting and restart
sudo cp ./config/nginx-rate-limit.conf /etc/nginx/nginx.conf
check_service nginx restart

# Run tests against the Nginx rate limiting configuration
run_test "Nginx Rate Limiting from Browser" "http://localhost:8080/api/unprotected" $UA_BROWSER

# Configure Nginx for bot protection and restart
sudo cp ./config/nginx-bot-protect.conf /etc/nginx/nginx.conf
check_service nginx restart

# Run tests against the Nginx bot protection configuration
run_test "Nginx Bot Protection from Browser" "http://localhost:8080/api/unprotected" $UA_BROWSER
run_test "Nginx Bot Protection from Curl" "http://localhost:8080/api/unprotected" $UA_CURL

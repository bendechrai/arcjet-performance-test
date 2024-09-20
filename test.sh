#!/bin/bash

# Define the user agents for use with bot detection tests
UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
UA_CURL="curl/7.88.1"

# Function to run apache-bench tests
run_test() {
    local test_name=$1
    local url=$2
    local useragent=$3
    echo "---"
    echo "Test: $test_name"
    echo ""
    ab -n 1000 -c 1 -H "User-Agent: $useragent" $url
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

# Function to warm up the server
warm_up_server() {
    local port=$1
    echo -n "Warming up server on port $port"
    for i in {1..5}; do
        curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/unprotected
        curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/rate-limit
        curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/bot-detect
        curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/rate-and-bot
        echo -n "."
        sleep 1
    done
    echo " warm-up complete."
}

# Pre-warm Next.js routes
warm_up_server 3000

#####################################
# RUN TEST AGAINST NEXT.JS DIRECTLY #
#####################################
run_test "Next server : Baseline" "http://localhost:3000/api/unprotected" "$UA_BROWSER"
run_test "Next server : Aj Rate" "http://localhost:3000/api/rate-limit" "$UA_BROWSER"
run_test "Next server : Aj Bot (Browser)" "http://localhost:3000/api/bot-detect" "$UA_BROWSER"
sleep 61 # Aj Bot Protection has a 60s block cache, so we need to wait for it to expire
run_test "Next server : Aj Bot (Curl)" "http://localhost:3000/api/bot-detect" "$UA_CURL"
sleep 61
run_test "Next server : Aj Rate+Bot (Browser)" "http://localhost:3000/api/rate-and-bot" "$UA_BROWSER"
sleep 61
run_test "Next server : Aj Rate+Bot (Curl)" "http://localhost:3000/api/rate-and-bot" "$UA_CURL"
sleep 61
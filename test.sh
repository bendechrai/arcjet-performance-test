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

# Pre-warm Next.js routes
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:3000/api/unprotected
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:3000/api/rate-limit
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:3000/api/bot-detect
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:3000/api/rate-and-bot

#####################################
# RUN TEST AGAINST NEXT.JS DIRECTLY #
#####################################
run_test "Next server : Baseline" "http://localhost:3000/api/unprotected" $UA_BROWSER
run_test "Next server : Aj Rate" "http://localhost:3000/api/rate-limit" $UA_BROWSER
run_test "Next server : Aj Bot (Browser)" "http://localhost:3000/api/bot-detect" $UA_BROWSER
sleep 61 # Aj Bot Protection has a 60s block cache, so we need to wait for it to expire
run_test "Next server : Aj Bot (Curl)" "http://localhost:3000/api/bot-detect" $UA_CURL
sleep 61
run_test "Next server : Aj Rate+Bot (Browser)" "http://localhost:3000/api/rate-and-bot" $UA_BROWSER
sleep 61
run_test "Next server : Aj Rate+Bot (Curl)" "http://localhost:3000/api/rate-and-bot" $UA_CURL
sleep 61

################################
# RUN TEST AGAINST NGINX PROXY #
################################
sudo cp ./config/nginx.conf /etc/nginx/nginx.conf
check_service nginx restart
run_test "nginx proxy : Baseline" "http://localhost:8080/api/unprotected" $UA_BROWSER
run_test "nginx proxy : Aj Rate" "http://localhost:8080/api/rate-limit" $UA_BROWSER
run_test "nginx proxy : Aj Bot (Browser)" "http://localhost:8080/api/bot-detect" $UA_BROWSER
sleep 61
run_test "nginx proxy : Aj Bot (Curl)" "http://localhost:8080/api/bot-detect" $UA_CURL
sleep 61
run_test "nginx proxy : Aj Rate+Bot (Browser)" "http://localhost:8080/api/rate-and-bot" $UA_BROWSER
sleep 61
run_test "nginx proxy : Aj Rate+Bot (Curl)" "http://localhost:8080/api/rate-and-bot" $UA_CURL
sleep 61

###################################################
# RUN TEST AGAINST NGINX PROXY WITH RATE LIMITING #
###################################################
sudo cp ./config/nginx-rate-limit.conf /etc/nginx/nginx.conf
check_service nginx restart
run_test "nginx rate" "http://localhost:8080/api/unprotected" $UA_BROWSER

####################################################
# RUN TEST AGAINST NGINX PROXY WITH BOT PROTECTION #
####################################################
sudo cp ./config/nginx-bot-protect.conf /etc/nginx/nginx.conf
check_service nginx restart
run_test "nginx bot : Browser" "http://localhost:8080/api/unprotected" $UA_BROWSER
run_test "nginx bot : Curl" "http://localhost:8080/api/unprotected" $UA_CURL

###########################################################################
# RUN TEST AGAINST NGINX PROXY WITH BOTH RATE LIMITING AND BOT PROTECTION #
###########################################################################
sudo cp ./config/nginx-rate-and-bot.conf /etc/nginx/nginx.conf
check_service nginx restart
run_test "nginx rate+bot : Browser" "http://localhost:8080/api/unprotected" $UA_BROWSER
run_test "nginx rate+bot : Curl" "http://localhost:8080/api/unprotected" $UA_CURL

################################
# RUN TEST AGAINST CADDY PROXY #
################################
sudo cp ./config/caddy.conf /etc/caddy/Caddyfile
check_service caddy restart
run_test "caddy proxy : Baseline" "http://localhost:8081/api/unprotected" $UA_BROWSER
run_test "caddy proxy : Aj Rate" "http://localhost:8081/api/rate-limit" $UA_BROWSER
run_test "caddy proxy : Aj Bot (Browser)" "http://localhost:8081/api/bot-detect" $UA_BROWSER
sleep 61
run_test "caddy proxy : Aj Bot (Curl)" "http://localhost:8081/api/bot-detect" $UA_CURL
sleep 61
run_test "caddy proxy : Aj Rate+Bot (Browser)" "http://localhost:8081/api/rate-and-bot" $UA_BROWSER
sleep 61
run_test "caddy proxy : Aj Rate+Bot (Curl)" "http://localhost:8081/api/rate-and-bot" $UA_CURL
sleep 61

###################################################
# RUN TEST AGAINST CADDY PROXY WITH RATE LIMITING #
###################################################
sudo cp ./config/caddy-rate-limit.conf /etc/caddy/Caddyfile
check_service caddy restart
run_test "caddy rate" "http://localhost:8081/api/unprotected" $UA_BROWSER

####################################################
# RUN TEST AGAINST CADDY PROXY WITH BOT PROTECTION #
####################################################
sudo cp ./config/caddy-bot-protect.conf /etc/caddy/Caddyfile
check_service caddy restart
run_test "caddy bot : Browser" "http://localhost:8081/api/unprotected" $UA_BROWSER
run_test "caddy bot : Curl" "http://localhost:8081/api/unprotected" $UA_CURL

###########################################################################
# RUN TEST AGAINST CADDY PROXY WITH BOTH RATE LIMITING AND BOT PROTECTION #
###########################################################################
sudo cp ./config/caddy-rate-and-bot.conf /etc/caddy/Caddyfile
check_service caddy restart
run_test "caddy rate+bot : Browser" "http://localhost:8081/api/unprotected" $UA_BROWSER
run_test "caddy rate+bot : Curl" "http://localhost:8081/api/unprotected" $UA_CURL
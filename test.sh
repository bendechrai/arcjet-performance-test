#!/bin/bash

# Define the user agents for use with bot detection tests
UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36"
UA_CURL="curl/7.88.1"

# Function to run apache-bench tests
run_test() {
	local test_name=$1
	local url=$2
	local header=$3
	echo "Test: $test_name"
	ab -n 1000 -c 1 -H "$header" $url
	echo ""
}

# Function to check service status
check_service() {
	local service_name=$1
	local action=$2
	sudo service "$service_name" "$action"
	if [[ $? -ne 0 ]]; then
		echo "Failed to $action $service_name. Exiting."
		exit 1
	fi
}

# Pre-warm Next.js routes
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/unprotected
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/rate-limit
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/bot-detect
curl -s -o /dev/null -H "User-Agent: $UA_BROWSER" http://localhost:$port/api/rate-and-bot

# Baseline
run_test "Baseline" "http://localhost:3000/api/unprotected" "User-Agent: $UA_BROWSER"

# Shield
run_test "Shield" "http://localhost:3000/api/shield" "User-Agent: $UA_BROWSER"

# Rate Limit
run_test "Rate" "http://localhost:3000/api/rate-limit" "User-Agent: $UA_BROWSER"

# Bot Detection
run_test "Bot (USER)" "http://localhost:3000/api/bot-detect" "User-Agent: $UA_BROWSER"
run_test "Bot (BOT)" "http://localhost:3000/api/bot-detect" "User-Agent: $UA_CURL"
echo "Sleeping for 61 seconds to allow the bot detection cache to expire"
sleep 61

# Shield + Rate
run_test "Shield + Rate" "http://localhost:3000/api/rate-and-shield" "User-Agent: $UA_BROWSER"

# Shield + Bot
run_test "Shield + Bot (USER)" "http://localhost:3000/api/bot-and-shield" "User-Agent: $UA_BROWSER"
run_test "Shield + Bot (BOT)" "http://localhost:3000/api/bot-and-shield" "User-Agent: $UA_CURL"
echo "Sleeping for 61 seconds to allow the bot detection cache to expire"
sleep 61

# Rate Limit + Bot Detection
run_test "Rate + Bot (USER)" "http://localhost:3000/api/rate-and-bot" "User-Agent: $UA_BROWSER"
run_test "Rate + Bot (BOT)" "http://localhost:3000/api/rate-and-bot" "User-Agent: $UA_CURL"
echo "Sleeping for 61 seconds to allow the bot detection cache to expire"
sleep 61

# Shield + Rate + Bot
run_test "Shield + Rate + Bot (USER)" "http://localhost:3000/api/rate-and-bot-and-shield" "User-Agent: $UA_BROWSER"
run_test "Shield + Rate + Bot (BOT)" "http://localhost:3000/api/rate-and-bot-and-shield" "User-Agent: $UA_CURL"

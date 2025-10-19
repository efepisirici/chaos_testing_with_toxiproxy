#!/bin/bash

set -e

APP_URL="http://localhost:8087"
TOXIPROXY_API="http://localhost:8474"
PROXY_NAME="elasticsearch"

echo "Starting automated chaos testing..."

function reset_toxics() {
    echo "Cleaning all toxics..."
    toxics=$(curl -s "$TOXIPROXY_API/proxies/$PROXY_NAME" | jq -r '.toxics[].name')
    for toxic in $toxics; do
        echo " - Removing $toxic..."
        curl -s -X DELETE "$TOXIPROXY_API/proxies/$PROXY_NAME/toxics/$toxic" > /dev/null
    done
}

function ensure_proxy_exists() {
    echo "Ensuring proxy exists..."
    existing=$(curl -s "$TOXIPROXY_API/proxies" | jq -r "has(\"$PROXY_NAME\")")
    if [[ "$existing" != "true" ]]; then
        curl -s -X POST "$TOXIPROXY_API/proxies" \
            -H "Content-Type: application/json" \
            -d "{\"name\": \"$PROXY_NAME\", \"listen\": \"0.0.0.0:8666\", \"upstream\": \"elasticsearch:9200\"}" > /dev/null
    fi
}

function send_request() {
    echo "Sending GET request to app..."
    time curl -s "$APP_URL" || echo "Request failed"
}

ensure_proxy_exists

echo ""
echo "=== BASELINE ==="
reset_toxics
send_request

echo ""
echo "=== TEST: Latency ==="
reset_toxics
curl -s -X POST "$TOXIPROXY_API/proxies/$PROXY_NAME/toxics" \
    -H "Content-Type: application/json" \
    -d '{"name": "latency_downstream", "type": "latency", "stream": "downstream", "toxicity": 1.0, "attributes": {"latency": 3000, "jitter": 500}}' > /dev/null
send_request

echo ""
echo "=== TEST: Bandwidth Limit ==="
reset_toxics
curl -s -X POST "$TOXIPROXY_API/proxies/$PROXY_NAME/toxics" \
    -H "Content-Type: application/json" \
    -d '{"name": "bandwidth_limit", "type": "bandwidth", "stream": "downstream", "toxicity": 1.0, "attributes": {"rate": 100}}' > /dev/null
send_request

echo ""
echo "=== TEST: Cut Connection ==="
reset_toxics
curl -s -X POST "$TOXIPROXY_API/proxies/$PROXY_NAME/toxics" \
    -H "Content-Type: application/json" \
    -d '{"name": "timeout_cut", "type": "timeout", "stream": "downstream", "toxicity": 1.0, "attributes": {"timeout": 1000}}' > /dev/null
send_request

echo ""
echo "=== TEST: Upstream Latency ==="
reset_toxics
curl -s -X POST "$TOXIPROXY_API/proxies/$PROXY_NAME/toxics" \
    -H "Content-Type: application/json" \
    -d '{"name": "latency_upstream", "type": "latency", "stream": "upstream", "toxicity": 1.0, "attributes": {"latency": 1500, "jitter": 300}}' > /dev/null
send_request

echo ""
reset_toxics
echo "All chaos tests completed."

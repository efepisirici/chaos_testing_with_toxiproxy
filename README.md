# Chaos Testing with Toxiproxy and Docker

This project demonstrates how to perform **chaos testing** by simulating real-world network issues between services using **Toxiproxy**.

## What’s Inside

- **elasticsearch**: A sample backend search service.  
- **elastic_filter**: A Flask-based API that communicates with Elasticsearch.  
- **toxiproxy**: A proxy tool to simulate network chaos (latency, bandwidth, disconnections).  
- **nginx**: Reverse proxy to show request routing.  
- **chaos.sh**: A script to run predefined chaos scenarios and measure response.

## Getting Started

1. Clone this repository.  
2. Build and start services using Docker Compose.  
3. Run the chaos script to simulate various network conditions.  

## Scenarios Tested

- Downstream latency (delays responses from backend)  
- Bandwidth throttling (limits kbps)  
- Connection cut (simulates dropped connections)  
- Upstream latency (delays client requests)

## Dependencies

Make sure the following tools are installed:  
- Docker  
- Docker Compose  
- jq (used for JSON parsing in `chaos.sh`)

## Use Cases

- **Backend Engineers** – observe how backend services handle latency or timeouts.  
- **Frontend Engineers** – validate UI behavior under slow backend responses.  
- **QA Engineers** – include realistic chaos conditions in E2E tests.  
- **DevOps / SRE** – integrate chaos simulations into CI/CD or staging pipelines.  


All services communicate over the same Docker network using internal hostnames.

## Command Reference

```bash
# Build and run the environment
docker compose up -d --build
```
```bash
# Make the chaos test script executable
chmod +x chaos.sh
```
```bash
# Run automated chaos scenarios
./chaos.sh
```
```bash
# Install jq if missing
brew install jq  # macOS
sudo apt-get install jq  # Debian/Ubuntu
```
```bash
# Inspect current Toxiproxy state
curl http://localhost:8474/proxies | jq
```

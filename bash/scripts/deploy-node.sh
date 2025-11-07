#!/bin/bash

###############################################################################
# Ethereum Node Deployment Script
# Automates the deployment and management of Ethereum nodes
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NODE_TYPE="${NODE_TYPE:-geth}"
NETWORK="${NETWORK:-sepolia}"
DATA_DIR="${DATA_DIR:-./ethereum-data}"
HTTP_PORT="${HTTP_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

check_dependencies() {
    print_header "Checking Dependencies"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi

    print_success "All dependencies installed"
}

deploy_geth_node() {
    print_header "Deploying Geth Node"

    cat > docker-compose.yml <<EOF
version: '3.8'

services:
  geth:
    image: ethereum/client-go:latest
    container_name: ethereum-geth-${NETWORK}
    ports:
      - "${HTTP_PORT}:8545"
      - "${WS_PORT}:8546"
      - "30303:30303"
    volumes:
      - ${DATA_DIR}:/root/.ethereum
    command:
      - --${NETWORK}
      - --http
      - --http.addr=0.0.0.0
      - --http.port=8545
      - --http.api=eth,net,web3,personal
      - --ws
      - --ws.addr=0.0.0.0
      - --ws.port=8546
      - --ws.api=eth,net,web3
      - --syncmode=snap
    restart: unless-stopped
    networks:
      - ethereum-network

networks:
  ethereum-network:
    driver: bridge
EOF

    docker-compose up -d

    print_success "Geth node deployed on ${NETWORK}"
    print_info "HTTP RPC: http://localhost:${HTTP_PORT}"
    print_info "WS RPC: ws://localhost:${WS_PORT}"
}

deploy_hardhat_node() {
    print_header "Deploying Hardhat Local Node"

    cat > hardhat-node-docker-compose.yml <<EOF
version: '3.8'

services:
  hardhat:
    image: node:18-alpine
    container_name: hardhat-node
    working_dir: /app
    ports:
      - "${HTTP_PORT}:8545"
    command: >
      sh -c "npm install -g hardhat &&
             npx hardhat node --hostname 0.0.0.0"
    restart: unless-stopped
    networks:
      - ethereum-network

networks:
  ethereum-network:
    driver: bridge
EOF

    docker-compose -f hardhat-node-docker-compose.yml up -d

    print_success "Hardhat node deployed"
    print_info "RPC URL: http://localhost:${HTTP_PORT}"
}

check_node_status() {
    print_header "Checking Node Status"

    if docker ps | grep -q "ethereum-geth\|hardhat-node"; then
        print_success "Node is running"

        # Test RPC connection
        print_info "Testing RPC connection..."

        response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
            http://localhost:${HTTP_PORT})

        if [ -n "$response" ]; then
            block_number=$(echo "$response" | grep -o '"result":"[^"]*' | cut -d'"' -f4)
            print_success "Connected! Latest block: $block_number"
        else
            print_error "Failed to connect to RPC"
        fi
    else
        print_error "No node is running"
        exit 1
    fi
}

stop_node() {
    print_header "Stopping Node"

    docker-compose down
    docker-compose -f hardhat-node-docker-compose.yml down 2>/dev/null || true

    print_success "Node stopped"
}

show_logs() {
    print_header "Node Logs"

    if docker ps | grep -q "ethereum-geth"; then
        docker-compose logs -f geth
    elif docker ps | grep -q "hardhat-node"; then
        docker-compose -f hardhat-node-docker-compose.yml logs -f hardhat
    else
        print_error "No node is running"
    fi
}

cleanup() {
    print_header "Cleaning Up"

    read -p "This will remove all node data. Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        stop_node
        rm -rf "$DATA_DIR"
        rm -f docker-compose.yml hardhat-node-docker-compose.yml

        print_success "Cleanup complete"
    else
        print_info "Cleanup cancelled"
    fi
}

show_help() {
    cat << EOF
Ethereum Node Deployment Script

Usage: $0 [command] [options]

Commands:
    deploy-geth         Deploy Geth node
    deploy-hardhat      Deploy Hardhat local node
    status              Check node status
    stop                Stop running node
    logs                Show node logs
    cleanup             Remove all node data
    help                Show this help message

Options:
    NODE_TYPE           Type of node (geth, hardhat) [default: geth]
    NETWORK             Network to connect to (mainnet, sepolia, goerli) [default: sepolia]
    DATA_DIR            Data directory [default: ./ethereum-data]
    HTTP_PORT           HTTP RPC port [default: 8545]
    WS_PORT             WebSocket port [default: 8546]

Examples:
    $0 deploy-geth
    NETWORK=mainnet $0 deploy-geth
    HTTP_PORT=8555 $0 deploy-hardhat
    $0 status
    $0 logs

Environment Variables:
    Set any option as an environment variable:
    export NETWORK=mainnet
    export DATA_DIR=/mnt/ethereum
EOF
}

# Main script
main() {
    case "${1:-help}" in
        deploy-geth)
            check_dependencies
            deploy_geth_node
            ;;
        deploy-hardhat)
            check_dependencies
            deploy_hardhat_node
            ;;
        status)
            check_node_status
            ;;
        stop)
            stop_node
            ;;
        logs)
            show_logs
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

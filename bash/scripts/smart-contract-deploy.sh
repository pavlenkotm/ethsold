#!/bin/bash

###############################################################################
# Smart Contract Deployment Script
# Automates compilation and deployment of Solidity contracts
###############################################################################

set -e

# Configuration
CONTRACT_DIR="${CONTRACT_DIR:-./contracts}"
BUILD_DIR="${BUILD_DIR:-./build}"
NETWORK="${NETWORK:-localhost}"
RPC_URL="${RPC_URL:-http://localhost:8545}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

compile_contracts() {
    log_info "Compiling contracts..."

    if [ -f "hardhat.config.js" ]; then
        npx hardhat compile
        log_success "Contracts compiled with Hardhat"
    elif [ -f "foundry.toml" ]; then
        forge build
        log_success "Contracts compiled with Foundry"
    else
        log_error "No Hardhat or Foundry configuration found"
        exit 1
    fi
}

deploy_contract() {
    local contract_name=$1
    log_info "Deploying ${contract_name} to ${NETWORK}..."

    if [ -f "hardhat.config.js" ]; then
        npx hardhat run scripts/deploy.js --network "${NETWORK}"
    elif [ -f "foundry.toml" ]; then
        forge create --rpc-url "${RPC_URL}" \
            --private-key "${PRIVATE_KEY}" \
            "src/${contract_name}.sol:${contract_name}"
    fi

    log_success "${contract_name} deployed successfully"
}

verify_contract() {
    local contract_address=$1
    local constructor_args=$2

    log_info "Verifying contract at ${contract_address}..."

    if [ -f "hardhat.config.js" ]; then
        npx hardhat verify --network "${NETWORK}" \
            "${contract_address}" ${constructor_args}
    fi

    log_success "Contract verified"
}

run_tests() {
    log_info "Running tests..."

    if [ -f "hardhat.config.js" ]; then
        npx hardhat test
    elif [ -f "foundry.toml" ]; then
        forge test
    fi

    log_success "All tests passed"
}

main() {
    case "${1:-help}" in
        compile)
            compile_contracts
            ;;
        deploy)
            compile_contracts
            deploy_contract "${2:-SimpleToken}"
            ;;
        verify)
            verify_contract "$2" "$3"
            ;;
        test)
            run_tests
            ;;
        all)
            compile_contracts
            run_tests
            deploy_contract "${2:-SimpleToken}"
            ;;
        *)
            cat << EOF
Smart Contract Deployment Script

Usage: $0 [command] [options]

Commands:
    compile             Compile all contracts
    deploy <contract>   Deploy specific contract
    verify <address>    Verify contract on Etherscan
    test                Run contract tests
    all                 Compile, test, and deploy

Examples:
    $0 compile
    $0 deploy SimpleToken
    $0 verify 0x123...
    NETWORK=sepolia $0 deploy MyContract
EOF
            ;;
    esac
}

main "$@"

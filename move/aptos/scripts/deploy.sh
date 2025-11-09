#!/bin/bash
# Deployment script for Simple Token on Aptos

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Aptos Simple Token Deployment Script"
echo "========================================"

# Check if aptos CLI is installed
if ! command -v aptos &> /dev/null; then
    echo -e "${RED}❌ Aptos CLI not found!${NC}"
    echo "Install with: curl -fsSL \"https://aptos.dev/scripts/install_cli.py\" | python3"
    exit 1
fi

echo -e "${GREEN}✅ Aptos CLI found${NC}"

# Get network (default to devnet)
NETWORK=${1:-devnet}
echo "📡 Network: $NETWORK"

# Check if account is initialized
if [ ! -f ".aptos/config.yaml" ]; then
    echo -e "${YELLOW}⚠️  No Aptos account found. Initializing...${NC}"
    aptos init --network $NETWORK
else
    echo -e "${GREEN}✅ Aptos account configured${NC}"
fi

# Get account address
ACCOUNT=$(aptos config show-profiles --profile default | grep 'account' | awk '{print $2}')
echo "👤 Account: $ACCOUNT"

# Compile the module
echo ""
echo "📦 Compiling Move module..."
aptos move compile --named-addresses simple_token=$ACCOUNT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Compilation successful!${NC}"
else
    echo -e "${RED}❌ Compilation failed!${NC}"
    exit 1
fi

# Run tests
echo ""
echo "🧪 Running tests..."
aptos move test

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
fi

# Ask for confirmation to publish
echo ""
read -p "Do you want to publish the module to $NETWORK? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📤 Publishing module..."
    aptos move publish --named-addresses simple_token=$ACCOUNT --assume-yes

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Module published successfully!${NC}"
        echo ""
        echo "📝 Module Address: $ACCOUNT"
        echo ""
        echo "To initialize the token, run:"
        echo "  aptos move run \\"
        echo "    --function-id '$ACCOUNT::simple_token::initialize' \\"
        echo "    --args string:\"My Token\" string:\"MTK\" u8:8 u64:1000000"
    else
        echo -e "${RED}❌ Publishing failed!${NC}"
        exit 1
    fi
else
    echo "Cancelled."
    exit 0
fi

#!/bin/bash
# Script to interact with deployed Simple Token contract

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NETWORK=${NETWORK:-devnet}
MODULE_OWNER=${1:-default}

echo "🔧 Simple Token Interaction Script"
echo "===================================="
echo "Network: $NETWORK"
echo "Module Owner: $MODULE_OWNER"
echo ""

show_menu() {
    echo "Choose an action:"
    echo "1) Initialize token"
    echo "2) Mint tokens"
    echo "3) Transfer tokens"
    echo "4) Burn tokens"
    echo "5) Check balance"
    echo "6) Get total supply"
    echo "7) Get metadata"
    echo "0) Exit"
    echo ""
}

initialize_token() {
    read -p "Token Name: " name
    read -p "Token Symbol: " symbol
    read -p "Decimals (default 8): " decimals
    decimals=${decimals:-8}
    read -p "Initial Supply: " supply

    echo -e "${GREEN}Initializing token...${NC}"
    aptos move run \
        --function-id "$MODULE_OWNER::simple_token::initialize" \
        --args string:"$name" string:"$symbol" u8:$decimals u64:$supply
}

mint_tokens() {
    read -p "Recipient Address: " recipient
    read -p "Amount: " amount

    echo -e "${GREEN}Minting tokens...${NC}"
    aptos move run \
        --function-id "$MODULE_OWNER::simple_token::mint" \
        --args address:$recipient u64:$amount
}

transfer_tokens() {
    read -p "Recipient Address: " recipient
    read -p "Amount: " amount

    echo -e "${GREEN}Transferring tokens...${NC}"
    aptos move run \
        --function-id "$MODULE_OWNER::simple_token::transfer" \
        --args address:$recipient u64:$amount
}

burn_tokens() {
    read -p "Amount to burn: " amount

    echo -e "${GREEN}Burning tokens...${NC}"
    aptos move run \
        --function-id "$MODULE_OWNER::simple_token::burn" \
        --args u64:$amount
}

check_balance() {
    read -p "Account Address: " account

    echo -e "${GREEN}Checking balance...${NC}"
    aptos move view \
        --function-id "$MODULE_OWNER::simple_token::balance_of" \
        --args address:$account
}

get_total_supply() {
    echo -e "${GREEN}Getting total supply...${NC}"
    aptos move view \
        --function-id "$MODULE_OWNER::simple_token::total_supply" \
        --args address:$MODULE_OWNER
}

get_metadata() {
    echo -e "${GREEN}Getting token metadata...${NC}"
    aptos move view \
        --function-id "$MODULE_OWNER::simple_token::get_metadata" \
        --args address:$MODULE_OWNER
}

while true; do
    show_menu
    read -p "Select option: " choice
    echo ""

    case $choice in
        1) initialize_token ;;
        2) mint_tokens ;;
        3) transfer_tokens ;;
        4) burn_tokens ;;
        5) check_balance ;;
        6) get_total_supply ;;
        7) get_metadata ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${YELLOW}Invalid option${NC}" ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
    echo ""
done

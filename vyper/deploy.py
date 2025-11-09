#!/usr/bin/env python3
"""
Deployment script for ERC20Token.vy

Usage:
    python deploy.py --network <rpc_url> --private-key <key>

Example:
    python deploy.py --network http://localhost:8545 --private-key 0x...
"""

import argparse
import json
import subprocess
import sys
from web3 import Web3
from eth_account import Account


def compile_contract():
    """Compile the Vyper contract"""
    print("📦 Compiling ERC20Token.vy...")

    try:
        # Get ABI
        abi_result = subprocess.run(
            ['vyper', '-f', 'abi', 'ERC20Token.vy'],
            capture_output=True,
            text=True,
            check=True
        )
        abi = json.loads(abi_result.stdout)

        # Get bytecode
        bytecode_result = subprocess.run(
            ['vyper', '-f', 'bytecode', 'ERC20Token.vy'],
            capture_output=True,
            text=True,
            check=True
        )
        bytecode = bytecode_result.stdout.strip()

        print("✅ Compilation successful!")
        return {'abi': abi, 'bytecode': bytecode}

    except FileNotFoundError:
        print("❌ Error: Vyper compiler not found.")
        print("Install with: pip install vyper")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"❌ Compilation failed: {e.stderr}")
        sys.exit(1)


def deploy_contract(w3, compiled, deployer_account, name, symbol, decimals, supply):
    """Deploy the contract"""
    print(f"\n🚀 Deploying {name} ({symbol})...")
    print(f"   Decimals: {decimals}")
    print(f"   Initial Supply: {supply:,}")
    print(f"   Deployer: {deployer_account.address}")

    # Create contract instance
    Contract = w3.eth.contract(
        abi=compiled['abi'],
        bytecode=compiled['bytecode']
    )

    # Build constructor transaction
    construct_txn = Contract.constructor(
        name,
        symbol,
        decimals,
        supply
    ).build_transaction({
        'from': deployer_account.address,
        'nonce': w3.eth.get_transaction_count(deployer_account.address),
        'gas': 2000000,
        'gasPrice': w3.eth.gas_price
    })

    # Sign transaction
    signed_txn = deployer_account.sign_transaction(construct_txn)

    # Send transaction
    print("📤 Sending deployment transaction...")
    tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
    print(f"   Transaction hash: {tx_hash.hex()}")

    # Wait for confirmation
    print("⏳ Waiting for confirmation...")
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    if tx_receipt.status == 1:
        print(f"✅ Contract deployed successfully!")
        print(f"   Contract address: {tx_receipt.contractAddress}")
        print(f"   Block number: {tx_receipt.blockNumber}")
        print(f"   Gas used: {tx_receipt.gasUsed:,}")

        # Save deployment info
        deployment_info = {
            'network': w3.provider.endpoint_uri if hasattr(w3.provider, 'endpoint_uri') else 'unknown',
            'contract_address': tx_receipt.contractAddress,
            'deployer': deployer_account.address,
            'transaction_hash': tx_hash.hex(),
            'block_number': tx_receipt.blockNumber,
            'gas_used': tx_receipt.gasUsed,
            'token_info': {
                'name': name,
                'symbol': symbol,
                'decimals': decimals,
                'initial_supply': supply
            }
        }

        with open('deployment_info.json', 'w') as f:
            json.dump(deployment_info, f, indent=2)
        print("\n💾 Deployment info saved to deployment_info.json")

        # Save ABI
        with open('ERC20Token_abi.json', 'w') as f:
            json.dump(compiled['abi'], f, indent=2)
        print("💾 ABI saved to ERC20Token_abi.json")

        return tx_receipt.contractAddress
    else:
        print("❌ Deployment failed!")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description='Deploy ERC20Token.vy contract')
    parser.add_argument('--network', required=True, help='RPC URL')
    parser.add_argument('--private-key', required=True, help='Deployer private key')
    parser.add_argument('--name', default='VyperToken', help='Token name')
    parser.add_argument('--symbol', default='VYP', help='Token symbol')
    parser.add_argument('--decimals', type=int, default=18, help='Token decimals')
    parser.add_argument('--supply', type=int, default=1000000, help='Initial supply')

    args = parser.parse_args()

    print("🐍 Vyper ERC20 Token Deployment")
    print("=" * 50)

    # Connect to network
    print(f"\n🌐 Connecting to {args.network}...")
    w3 = Web3(Web3.HTTPProvider(args.network))

    if not w3.is_connected():
        print("❌ Failed to connect to network")
        sys.exit(1)

    print(f"✅ Connected! Chain ID: {w3.eth.chain_id}")

    # Load deployer account
    deployer_account = Account.from_key(args.private_key)
    balance = w3.eth.get_balance(deployer_account.address)
    print(f"💰 Deployer balance: {w3.from_wei(balance, 'ether')} ETH")

    if balance == 0:
        print("⚠️  Warning: Deployer has zero balance!")

    # Compile contract
    compiled = compile_contract()

    # Deploy contract
    contract_address = deploy_contract(
        w3,
        compiled,
        deployer_account,
        args.name,
        args.symbol,
        args.decimals,
        args.supply
    )

    print("\n" + "=" * 50)
    print("🎉 Deployment complete!")
    print(f"📝 Contract address: {contract_address}")
    print("=" * 50)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Web3 Wallet Manager - CLI tool for Ethereum wallet operations
Demonstrates Web3.py usage for blockchain interactions
"""

import sys
from decimal import Decimal
import os
from web3 import Web3
from eth_account import Account
from eth_account.messages import encode_defunct


class WalletManager:
    """Manages Ethereum wallet operations using Web3.py"""

    def __init__(self, rpc_url: str = "http://localhost:8545"):
        """
        Initialize wallet manager with RPC connection

        Args:
            rpc_url: Ethereum node RPC URL
        """
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        if not self.w3.is_connected():
            raise ConnectionError(f"Failed to connect to {rpc_url}")
        print(f"✅ Connected to Ethereum node at {rpc_url}")
        print(f"⛓️  Chain ID: {self.w3.eth.chain_id}")
        print(f"📦 Latest block: {self.w3.eth.block_number}")

    def create_wallet(self) -> tuple[str, str]:
        """
        Create a new Ethereum wallet

        Returns:
            Tuple of (address, private_key)
        """
        account = Account.create()
        return account.address, account.key.hex()

    def get_balance(self, address: str) -> Decimal:
        """
        Get ETH balance of an address

        Args:
            address: Ethereum address

        Returns:
            Balance in ETH
        """
        checksum_address = self.w3.to_checksum_address(address)
        balance_wei = self.w3.eth.get_balance(checksum_address)
        balance_eth = self.w3.from_wei(balance_wei, 'ether')
        return Decimal(str(balance_eth))

    def send_transaction(
        self,
        private_key: str,
        to_address: str,
        amount_eth: float,
        gas_price_gwei: int = 50,
        gas_limit: int | None = None,
        use_eip1559: bool = False
    ) -> str:
        """
        Send ETH transaction

        Args:
            private_key: Sender's private key
            to_address: Recipient address
            amount_eth: Amount in ETH
            gas_price_gwei: Gas price in Gwei
            gas_limit: Optional gas limit (auto-estimated when omitted)
            use_eip1559: Use dynamic fee market transaction with fee history oracle

        Returns:
            Transaction hash
        """
        account = Account.from_key(private_key)
        from_address = account.address

        nonce = self.w3.eth.get_transaction_count(from_address)
        base_tx = {
            'nonce': nonce,
            'to': self.w3.to_checksum_address(to_address),
            'value': self.w3.to_wei(amount_eth, 'ether'),
            'chainId': self.w3.eth.chain_id,
            'from': from_address,
        }

        if gas_limit is None:
            try:
                gas_limit = self.w3.eth.estimate_gas(base_tx)
            except Exception:
                gas_limit = 21000

        if use_eip1559:
            fees = self.estimate_dynamic_fees()
            tx = {
                **base_tx,
                'gas': gas_limit,
                'maxPriorityFeePerGas': fees['priorityFeeWei'],
                'maxFeePerGas': fees['maxFeeWei'],
                'type': 2,
            }
        else:
            tx = {
                **base_tx,
                'gas': gas_limit,
                'gasPrice': self.w3.to_wei(gas_price_gwei, 'gwei'),
            }

        # Sign and send
        signed_tx = self.w3.eth.account.sign_transaction(tx, private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)

        return tx_hash.hex()

    def estimate_dynamic_fees(self, blocks: int = 5, percentile: int = 60) -> dict:
        """
        Suggest EIP-1559 fee parameters using fee_history oracle.

        Args:
            blocks: Number of recent blocks to sample
            percentile: Priority fee percentile to target (0-100)

        Returns:
            Dictionary with baseFeeWei, priorityFeeWei, maxFeeWei and Gwei conversions
        """
        history = self.w3.eth.fee_history(blocks, 'latest', [percentile])
        base_fee_wei = int(history['baseFeePerGas'][-1])
        rewards = history.get('reward', [[self.w3.to_wei(2, 'gwei')]])
        priority_fee_wei = int(rewards[-1][0]) if rewards and rewards[-1] else self.w3.to_wei(2, 'gwei')
        # Be defensive against sudden base fee doubling
        max_fee_wei = base_fee_wei * 2 + priority_fee_wei

        return {
            'baseFeeWei': base_fee_wei,
            'priorityFeeWei': priority_fee_wei,
            'maxFeeWei': max_fee_wei,
            'baseFeeGwei': Decimal(str(self.w3.from_wei(base_fee_wei, 'gwei'))),
            'priorityFeeGwei': Decimal(str(self.w3.from_wei(priority_fee_wei, 'gwei'))),
            'maxFeeGwei': Decimal(str(self.w3.from_wei(max_fee_wei, 'gwei'))),
        }

    def get_transaction_receipt(self, tx_hash: str) -> dict:
        """
        Get transaction receipt

        Args:
            tx_hash: Transaction hash

        Returns:
            Receipt dictionary
        """
        receipt = self.w3.eth.get_transaction_receipt(tx_hash)
        return {
            'status': 'success' if receipt['status'] == 1 else 'failed',
            'blockNumber': receipt['blockNumber'],
            'gasUsed': receipt['gasUsed'],
            'from': receipt['from'],
            'to': receipt['to'],
        }

    def call_contract_function(
        self,
        contract_address: str,
        abi: list,
        function_name: str,
        *args
    ):
        """
        Call a read-only contract function

        Args:
            contract_address: Contract address
            abi: Contract ABI
            function_name: Function name
            *args: Function arguments

        Returns:
            Function return value
        """
        contract = self.w3.eth.contract(
            address=self.w3.to_checksum_address(contract_address),
            abi=abi
        )
        return getattr(contract.functions, function_name)(*args).call()

    def sign_message(self, private_key: str, message: str) -> str:
        """
        Sign a message with private key using EIP-191 standard

        Args:
            private_key: Signer's private key
            message: Message to sign

        Returns:
            Signature (hex string)
        """
        account = Account.from_key(private_key)
        # Use EIP-191 message encoding (same format as MetaMask)
        message_encoded = encode_defunct(text=message)
        signed = account.sign_message(message_encoded)
        return signed.signature.hex()

    def verify_signature(
        self,
        message: str,
        signature: str,
        expected_address: str
    ) -> bool:
        """
        Verify a message signature using EIP-191 standard

        Args:
            message: Original message
            signature: Signature to verify (hex string with or without 0x prefix)
            expected_address: Expected signer address

        Returns:
            True if signature is valid
        """
        # Use EIP-191 message encoding (same format as MetaMask)
        message_encoded = encode_defunct(text=message)
        # Remove 0x prefix if present
        sig_bytes = bytes.fromhex(signature[2:] if signature.startswith('0x') else signature)
        recovered_address = Account.recover_message(
            message_encoded,
            signature=sig_bytes
        )
        return recovered_address.lower() == expected_address.lower()


def main():
    """CLI interface for wallet manager"""
    if len(sys.argv) < 2:
        print("""
Web3 Wallet Manager CLI

Usage:
  python wallet_manager.py create                    Create new wallet
  python wallet_manager.py balance <address>         Get ETH balance
  python wallet_manager.py send <key> <to> <amount>  Send ETH
  python wallet_manager.py send1559 <key> <to> <amount>  Send ETH with dynamic fees
  python wallet_manager.py fees                      Show EIP-1559 fee suggestion
  python wallet_manager.py sign <key> <message>      Sign message

Environment Variables:
  WEB3_RPC_URL - Ethereum RPC URL (default: http://localhost:8545)
        """)
        sys.exit(1)

    rpc_url = os.getenv('WEB3_RPC_URL', 'http://localhost:8545')
    manager = WalletManager(rpc_url)

    command = sys.argv[1]

    if command == 'create':
        address, private_key = manager.create_wallet()
        print(f"\n🎉 New wallet created!")
        print(f"Address: {address}")
        print(f"Private Key: {private_key}")
        print(f"\n⚠️  NEVER share your private key!")

    elif command == 'balance':
        if len(sys.argv) < 3:
            print("Usage: python wallet_manager.py balance <address>")
            sys.exit(1)
        address = sys.argv[2]
        balance = manager.get_balance(address)
        print(f"\n💰 Balance of {address}")
        print(f"{balance} ETH")

    elif command == 'send':
        if len(sys.argv) < 5:
            print("Usage: python wallet_manager.py send <private_key> <to_address> <amount_eth>")
            sys.exit(1)
        private_key = sys.argv[2]
        to_address = sys.argv[3]
        amount = float(sys.argv[4])

        print(f"\n📤 Sending {amount} ETH to {to_address}...")
        tx_hash = manager.send_transaction(private_key, to_address, amount)
        print(f"✅ Transaction sent!")
        print(f"TX Hash: {tx_hash}")

    elif command == 'send1559':
        if len(sys.argv) < 5:
            print("Usage: python wallet_manager.py send1559 <private_key> <to_address> <amount_eth>")
            sys.exit(1)
        private_key = sys.argv[2]
        to_address = sys.argv[3]
        amount = float(sys.argv[4])

        fees = manager.estimate_dynamic_fees()
        print("\n⛽ Using dynamic fee market suggestions:")
        print(f"  Base fee: {fees['baseFeeGwei']} gwei")
        print(f"  Priority fee: {fees['priorityFeeGwei']} gwei")
        print(f"  Max fee: {fees['maxFeeGwei']} gwei")

        print(f"\n📤 Sending {amount} ETH to {to_address} with EIP-1559 fees...")
        tx_hash = manager.send_transaction(
            private_key,
            to_address,
            amount,
            use_eip1559=True,
            gas_limit=25000,
        )
        print(f"✅ Transaction sent!")
        print(f"TX Hash: {tx_hash}")

    elif command == 'fees':
        fees = manager.estimate_dynamic_fees()
        print("\n📊 EIP-1559 Fee Recommendation")
        print(f"Base fee: {fees['baseFeeGwei']} gwei")
        print(f"Priority fee (@60th percentile): {fees['priorityFeeGwei']} gwei")
        print(f"Max fee (base*2 + priority): {fees['maxFeeGwei']} gwei")

    elif command == 'sign':
        if len(sys.argv) < 4:
            print("Usage: python wallet_manager.py sign <private_key> <message>")
            sys.exit(1)
        private_key = sys.argv[2]
        message = sys.argv[3]

        signature = manager.sign_message(private_key, message)
        print(f"\n✍️  Message signed!")
        print(f"Signature: {signature}")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()

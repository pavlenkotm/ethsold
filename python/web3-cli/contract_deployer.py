#!/usr/bin/env python3
"""
Smart Contract Deployer - Deploy and interact with Ethereum contracts
"""

from web3 import Web3
from eth_account import Account
from solcx import compile_source, install_solc, get_installed_solc_versions


class ContractDeployer:
    """Deploy and interact with smart contracts"""

    def __init__(self, rpc_url: str, private_key: str):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        self.account = Account.from_key(private_key)
        self.address = self.account.address

        if not self.w3.is_connected():
            raise ConnectionError("Failed to connect to Ethereum node")

    def compile_contract(self, source_code: str, contract_name: str) -> tuple[list, str]:
        """
        Compile Solidity source code

        Args:
            source_code: Solidity source code
            contract_name: Name of the contract

        Returns:
            Tuple of (abi, bytecode)
        """
        # Install specific Solidity version if needed (only if not already installed)
        from packaging import version as pkg_version
        solc_version = '0.8.20'
        installed_versions = get_installed_solc_versions()
        if not any(str(v) == solc_version for v in installed_versions):
            print(f"Installing Solidity compiler {solc_version}...")
            install_solc(solc_version)

        compiled_sol = compile_source(
            source_code,
            output_values=['abi', 'bin']
        )

        contract_interface = compiled_sol[f'<stdin>:{contract_name}']
        return contract_interface['abi'], contract_interface['bin']

    def deploy_contract(self, abi: list[dict], bytecode: str, *constructor_args) -> str:
        """
        Deploy a smart contract

        Args:
            abi: Contract ABI
            bytecode: Contract bytecode
            *constructor_args: Constructor arguments

        Returns:
            Contract address
        """
        contract = self.w3.eth.contract(abi=abi, bytecode=bytecode)

        # Build deployment transaction
        nonce = self.w3.eth.get_transaction_count(self.address)
        tx = contract.constructor(*constructor_args).build_transaction({
            'from': self.address,
            'nonce': nonce,
            'gas': 3000000,
            'gasPrice': self.w3.eth.gas_price
        })

        # Sign and send
        signed_tx = self.w3.eth.account.sign_transaction(tx, self.account.key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)

        # Wait for receipt
        print(f"⏳ Waiting for deployment... TX: {tx_hash.hex()}")
        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)

        contract_address = receipt['contractAddress']
        print(f"✅ Contract deployed at: {contract_address}")

        return contract_address

    def call_function(
        self,
        contract_address: str,
        abi: list[dict],
        function_name: str,
        *args
    ) -> any:
        """
        Call a read-only contract function

        Args:
            contract_address: Contract address
            abi: Contract ABI
            function_name: Function name to call
            *args: Function arguments

        Returns:
            Function return value (type depends on contract function)
        """
        contract = self.w3.eth.contract(
            address=self.w3.to_checksum_address(contract_address),
            abi=abi
        )
        return getattr(contract.functions, function_name)(*args).call()

    def send_transaction(
        self,
        contract_address: str,
        abi: list,
        function_name: str,
        *args
    ) -> str:
        """Send a state-changing transaction"""
        contract = self.w3.eth.contract(
            address=self.w3.to_checksum_address(contract_address),
            abi=abi
        )

        nonce = self.w3.eth.get_transaction_count(self.address)
        tx = getattr(contract.functions, function_name)(*args).build_transaction({
            'from': self.address,
            'nonce': nonce,
            'gas': 200000,
            'gasPrice': self.w3.eth.gas_price
        })

        signed_tx = self.w3.eth.account.sign_transaction(tx, self.account.key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)

        return tx_hash.hex()


# Example ERC20 contract source
SIMPLE_TOKEN = """
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }
}
"""


if __name__ == "__main__":
    # Example usage
    print("Smart Contract Deployer Example")
    print("This is a library module - import in your scripts")

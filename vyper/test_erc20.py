"""
Test suite for ERC20Token.vy
"""
import pytest
from eth_tester import EthereumTester
from web3 import Web3
from web3.providers.eth_tester import EthereumTesterProvider
import json
import subprocess


@pytest.fixture
def w3():
    """Create a Web3 instance with EthereumTester backend"""
    tester = EthereumTester()
    provider = EthereumTesterProvider(tester)
    return Web3(provider)


@pytest.fixture
def accounts(w3):
    """Get test accounts"""
    return w3.eth.accounts


@pytest.fixture
def contract_source():
    """Read the Vyper contract source code"""
    with open('ERC20Token.vy', 'r') as f:
        return f.read()


@pytest.fixture
def compiled_contract(contract_source):
    """Compile the Vyper contract"""
    # Compile using vyper command-line tool
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

        return {'abi': abi, 'bytecode': bytecode}
    except FileNotFoundError:
        pytest.skip("Vyper compiler not found. Install with: pip install vyper")
    except subprocess.CalledProcessError as e:
        pytest.fail(f"Vyper compilation failed: {e.stderr}")


@pytest.fixture
def token_contract(w3, accounts, compiled_contract):
    """Deploy the ERC20 token contract"""
    # Deploy contract
    Contract = w3.eth.contract(
        abi=compiled_contract['abi'],
        bytecode=compiled_contract['bytecode']
    )

    # Deploy with constructor args
    tx_hash = Contract.constructor(
        "VyperToken",  # name
        "VYP",         # symbol
        18,            # decimals
        1000000        # supply (will be multiplied by 10^18)
    ).transact({'from': accounts[0]})

    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    contract = w3.eth.contract(
        address=tx_receipt.contractAddress,
        abi=compiled_contract['abi']
    )

    return contract


class TestERC20Token:
    """Test cases for ERC20Token contract"""

    def test_deployment(self, token_contract, accounts):
        """Test contract deployment and initial state"""
        assert token_contract.functions.name().call() == "VyperToken"
        assert token_contract.functions.symbol().call() == "VYP"
        assert token_contract.functions.decimals().call() == 18
        assert token_contract.functions.owner().call() == accounts[0]

        # Check initial supply (1M tokens * 10^18)
        expected_supply = 1000000 * 10**18
        assert token_contract.functions.totalSupply().call() == expected_supply
        assert token_contract.functions.balanceOf(accounts[0]).call() == expected_supply

    def test_transfer(self, w3, token_contract, accounts):
        """Test token transfer"""
        sender = accounts[0]
        recipient = accounts[1]
        amount = 1000 * 10**18  # 1000 tokens

        # Get initial balances
        sender_balance_before = token_contract.functions.balanceOf(sender).call()
        recipient_balance_before = token_contract.functions.balanceOf(recipient).call()

        # Transfer tokens
        tx_hash = token_contract.functions.transfer(
            recipient, amount
        ).transact({'from': sender})
        w3.eth.wait_for_transaction_receipt(tx_hash)

        # Check balances after transfer
        assert token_contract.functions.balanceOf(sender).call() == sender_balance_before - amount
        assert token_contract.functions.balanceOf(recipient).call() == recipient_balance_before + amount

    def test_transfer_insufficient_balance(self, w3, token_contract, accounts):
        """Test transfer with insufficient balance fails"""
        sender = accounts[1]  # Account with no tokens
        recipient = accounts[2]
        amount = 1000 * 10**18

        with pytest.raises(Exception):
            tx_hash = token_contract.functions.transfer(
                recipient, amount
            ).transact({'from': sender})
            w3.eth.wait_for_transaction_receipt(tx_hash)

    def test_approve_and_allowance(self, w3, token_contract, accounts):
        """Test approve function and allowance"""
        owner = accounts[0]
        spender = accounts[1]
        amount = 500 * 10**18

        # Approve spender
        tx_hash = token_contract.functions.approve(
            spender, amount
        ).transact({'from': owner})
        w3.eth.wait_for_transaction_receipt(tx_hash)

        # Check allowance
        assert token_contract.functions.allowance(owner, spender).call() == amount

    def test_transfer_from(self, w3, token_contract, accounts):
        """Test transferFrom with allowance"""
        owner = accounts[0]
        spender = accounts[1]
        recipient = accounts[2]
        amount = 500 * 10**18

        # Approve spender
        tx_hash = token_contract.functions.approve(
            spender, amount
        ).transact({'from': owner})
        w3.eth.wait_for_transaction_receipt(tx_hash)

        # Get balances before
        owner_balance_before = token_contract.functions.balanceOf(owner).call()
        recipient_balance_before = token_contract.functions.balanceOf(recipient).call()

        # Transfer from owner to recipient via spender
        tx_hash = token_contract.functions.transferFrom(
            owner, recipient, amount
        ).transact({'from': spender})
        w3.eth.wait_for_transaction_receipt(tx_hash)

        # Check balances after
        assert token_contract.functions.balanceOf(owner).call() == owner_balance_before - amount
        assert token_contract.functions.balanceOf(recipient).call() == recipient_balance_before + amount

        # Check allowance is reduced
        assert token_contract.functions.allowance(owner, spender).call() == 0

    def test_transfer_from_insufficient_allowance(self, w3, token_contract, accounts):
        """Test transferFrom with insufficient allowance fails"""
        owner = accounts[0]
        spender = accounts[1]
        recipient = accounts[2]
        amount = 500 * 10**18

        # Try to transfer without approval
        with pytest.raises(Exception):
            tx_hash = token_contract.functions.transferFrom(
                owner, recipient, amount
            ).transact({'from': spender})
            w3.eth.wait_for_transaction_receipt(tx_hash)

    def test_mint(self, w3, token_contract, accounts):
        """Test minting new tokens (owner only)"""
        owner = accounts[0]
        recipient = accounts[1]
        mint_amount = 10000 * 10**18

        total_supply_before = token_contract.functions.totalSupply().call()
        recipient_balance_before = token_contract.functions.balanceOf(recipient).call()

        # Mint tokens
        tx_hash = token_contract.functions.mint(
            recipient, mint_amount
        ).transact({'from': owner})
        w3.eth.wait_for_transaction_receipt(tx_hash)

        # Check total supply increased
        assert token_contract.functions.totalSupply().call() == total_supply_before + mint_amount

        # Check recipient balance increased
        assert token_contract.functions.balanceOf(recipient).call() == recipient_balance_before + mint_amount

    def test_mint_non_owner(self, w3, token_contract, accounts):
        """Test that non-owner cannot mint"""
        non_owner = accounts[1]
        recipient = accounts[2]
        mint_amount = 1000 * 10**18

        with pytest.raises(Exception):
            tx_hash = token_contract.functions.mint(
                recipient, mint_amount
            ).transact({'from': non_owner})
            w3.eth.wait_for_transaction_receipt(tx_hash)

    def test_burn(self, w3, token_contract, accounts):
        """Test burning tokens"""
        account = accounts[0]
        burn_amount = 1000 * 10**18

        total_supply_before = token_contract.functions.totalSupply().call()
        balance_before = token_contract.functions.balanceOf(account).call()

        # Burn tokens
        tx_hash = token_contract.functions.burn(
            burn_amount
        ).transact({'from': account})
        w3.eth.wait_for_transaction_receipt(tx_hash)

        # Check total supply decreased
        assert token_contract.functions.totalSupply().call() == total_supply_before - burn_amount

        # Check balance decreased
        assert token_contract.functions.balanceOf(account).call() == balance_before - burn_amount

    def test_burn_insufficient_balance(self, w3, token_contract, accounts):
        """Test burning more than balance fails"""
        account = accounts[1]  # Account with no tokens
        burn_amount = 1000 * 10**18

        with pytest.raises(Exception):
            tx_hash = token_contract.functions.burn(
                burn_amount
            ).transact({'from': account})
            w3.eth.wait_for_transaction_receipt(tx_hash)

    def test_events(self, w3, token_contract, accounts):
        """Test that events are emitted correctly"""
        sender = accounts[0]
        recipient = accounts[1]
        amount = 100 * 10**18

        # Transfer and get transaction receipt
        tx_hash = token_contract.functions.transfer(
            recipient, amount
        ).transact({'from': sender})
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

        # Check that Transfer event was emitted
        assert len(receipt['logs']) > 0

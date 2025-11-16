"""
Unit tests for WalletManager
"""

import pytest
from decimal import Decimal
from unittest.mock import Mock, patch
from wallet_manager import WalletManager


class TestWalletManager:
    """Test suite for WalletManager class"""

    @patch('wallet_manager.Web3')
    def test_initialization(self, mock_web3):
        """Test WalletManager initialization"""
        mock_web3_instance = Mock()
        mock_web3_instance.is_connected.return_value = True
        mock_web3_instance.eth.chain_id = 1
        mock_web3_instance.eth.block_number = 12345
        mock_web3.return_value = mock_web3_instance

        manager = WalletManager("http://localhost:8545")

        assert manager.w3 is not None
        mock_web3_instance.is_connected.assert_called_once()

    def test_create_wallet(self):
        """Test wallet creation"""
        with patch('wallet_manager.Web3') as mock_web3:
            mock_web3_instance = Mock()
            mock_web3_instance.is_connected.return_value = True
            mock_web3.return_value = mock_web3_instance

            manager = WalletManager()
            address, private_key = manager.create_wallet()

            assert address.startswith('0x')
            assert len(address) == 42
            assert private_key.startswith('0x')
            assert len(private_key) == 66

    @patch('wallet_manager.Web3')
    def test_get_balance(self, mock_web3):
        """Test balance retrieval"""
        mock_web3_instance = Mock()
        mock_web3_instance.is_connected.return_value = True
        mock_web3_instance.eth.get_balance.return_value = 1000000000000000000
        mock_web3_instance.from_wei.return_value = '1.0'
        mock_web3_instance.to_checksum_address.return_value = '0x123'
        mock_web3.return_value = mock_web3_instance

        manager = WalletManager()
        balance = manager.get_balance('0x123')

        assert balance is not None
        mock_web3_instance.eth.get_balance.assert_called_once()

    def test_sign_message(self):
        """Test message signing"""
        with patch('wallet_manager.Web3') as mock_web3:
            mock_web3_instance = Mock()
            mock_web3_instance.is_connected.return_value = True
            mock_web3_instance.keccak.return_value = b'hash'
            mock_web3.return_value = mock_web3_instance

            manager = WalletManager()
            private_key = '0x' + '1' * 64
            message = "Test message"

            signature = manager.sign_message(private_key, message)

            assert signature is not None
            assert isinstance(signature, str)

    @patch('wallet_manager.Web3')
    def test_estimate_dynamic_fees(self, mock_web3):
        """Fee oracle should return defensive EIP-1559 values"""
        web3_instance = Mock()
        web3_instance.is_connected.return_value = True
        web3_instance.to_wei.side_effect = lambda value, unit='ether': int(
            value * (10 ** 18 if unit == 'ether' else 10 ** 9)
        )
        web3_instance.from_wei.side_effect = lambda value, unit='ether': Decimal(value) / (
            Decimal(10) ** (18 if unit == 'ether' else 9)
        )
        eth = Mock()
        eth.chain_id = 1
        eth.block_number = 100
        eth.fee_history.return_value = {
            'baseFeePerGas': [1000000000, 1200000000],
            'reward': [[2000000000], [3000000000]],
        }
        web3_instance.eth = eth
        mock_web3.return_value = web3_instance

        manager = WalletManager()
        fees = manager.estimate_dynamic_fees()

        assert fees['baseFeeWei'] == 1200000000
        assert fees['priorityFeeWei'] == 3000000000
        assert fees['maxFeeWei'] == 5400000000  # base * 2 + priority

    @patch('wallet_manager.Web3')
    def test_send_transaction_eip1559(self, mock_web3):
        """Send transaction should support dynamic EIP-1559 fields"""
        web3_instance = Mock()
        web3_instance.is_connected.return_value = True
        web3_instance.to_checksum_address.return_value = '0xabc'
        web3_instance.to_wei.side_effect = lambda value, unit='ether': int(
            value * (10 ** 18 if unit == 'ether' else 10 ** 9)
        )
        web3_instance.from_wei.side_effect = lambda value, unit='ether': Decimal(value) / (
            Decimal(10) ** (18 if unit == 'ether' else 9)
        )

        eth = Mock()
        eth.chain_id = 1
        eth.block_number = 123
        eth.get_transaction_count.return_value = 0
        eth.estimate_gas.return_value = 25000
        eth.fee_history.return_value = {
            'baseFeePerGas': [1000000000, 1500000000],
            'reward': [[2000000000], [2500000000]],
        }
        sign_result = Mock()
        sign_result.rawTransaction = b'raw_tx'
        eth.account = Mock()
        eth.account.sign_transaction.return_value = sign_result
        eth.send_raw_transaction.return_value = b'\x12\x34'
        web3_instance.eth = eth
        mock_web3.return_value = web3_instance

        manager = WalletManager()
        tx_hash = manager.send_transaction(
            private_key='0x' + '1' * 64,
            to_address='0xdef',
            amount_eth=0.01,
            use_eip1559=True,
        )

        eth.account.sign_transaction.assert_called_once()
        assert tx_hash == '1234'


if __name__ == '__main__':
    pytest.main([__file__, '-v'])

"""
Unit tests for WalletManager
"""

import pytest
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


if __name__ == '__main__':
    pytest.main([__file__, '-v'])

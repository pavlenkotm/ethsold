import Foundation
import web3swift
import Web3Core
import BigInt

/// Web3 Wallet Manager for iOS/macOS
/// Provides wallet operations using web3swift library
public class WalletManager {

    public let rpcURL: String
    private var web3: Web3?

    public init(rpcURL: String = "http://localhost:8545") {
        self.rpcURL = rpcURL
        setupWeb3()
    }

    private func setupWeb3() {
        guard let url = URL(string: rpcURL) else {
            print("❌ Invalid RPC URL")
            return
        }

        let provider = try? Web3HttpProvider(url: url)
        self.web3 = Web3(provider: provider!)
    }

    /// Create a new Ethereum wallet
    /// - Returns: Wallet address and private key
    public func createWallet() throws -> (address: String, privateKey: String) {
        guard let keystore = try? EthereumKeystoreV3(password: "") else {
            throw WalletError.keystoreCreationFailed
        }

        guard let address = keystore.addresses?.first else {
            throw WalletError.addressNotFound
        }

        guard let privateKeyData = try? keystore.UNSAFE_getPrivateKeyData(
            account: address,
            password: ""
        ) else {
            throw WalletError.privateKeyExtractionFailed
        }

        let privateKey = privateKeyData.toHexString()
        print("🎉 New wallet created!")
        print("Address: \(address.address)")

        return (address.address, privateKey)
    }

    /// Get ETH balance of an address
    /// - Parameter address: Ethereum address
    /// - Returns: Balance in ETH
    public func getBalance(address: String) async throws -> String {
        guard let web3 = web3 else {
            throw WalletError.web3NotInitialized
        }

        let ethAddress = EthereumAddress(address)!
        let balance = try await web3.eth.getBalance(for: ethAddress)

        let balanceString = Web3.Utils.formatToEthereumUnits(
            balance,
            toUnits: .eth,
            decimals: 4
        ) ?? "0"

        print("💰 Balance: \(balanceString) ETH")
        return balanceString
    }

    /// Get latest block number
    /// - Returns: Block number
    public func getBlockNumber() async throws -> BigUInt {
        guard let web3 = web3 else {
            throw WalletError.web3NotInitialized
        }

        let blockNumber = try await web3.eth.blockNumber()
        print("📦 Latest block: \(blockNumber)")
        return blockNumber
    }

    /// Send ETH transaction
    /// - Parameters:
    ///   - privateKey: Sender's private key
    ///   - toAddress: Recipient address
    ///   - amount: Amount in ETH
    /// - Returns: Transaction hash
    public func sendTransaction(
        privateKey: String,
        toAddress: String,
        amount: String
    ) async throws -> String {
        guard let web3 = web3 else {
            throw WalletError.web3NotInitialized
        }

        // Create keystore from private key
        guard let privateKeyData = Data.fromHex(privateKey) else {
            throw WalletError.invalidPrivateKey
        }

        guard let keystore = try? EthereumKeystoreV3(
            privateKey: privateKeyData,
            password: ""
        ) else {
            throw WalletError.keystoreCreationFailed
        }

        guard let fromAddress = keystore.addresses?.first else {
            throw WalletError.addressNotFound
        }

        let toEthAddress = EthereumAddress(toAddress)!

        // Convert amount to Wei
        guard let amountWei = Web3.Utils.parseToBigUInt(
            amount,
            units: .eth
        ) else {
            throw WalletError.invalidAmount
        }

        // Create transaction
        var transaction = CodableTransaction(
            to: toEthAddress,
            value: amountWei,
            data: Data()
        )

        // Estimate gas
        let gasEstimate = try await web3.eth.estimateGas(for: transaction)
        transaction.gasLimit = gasEstimate

        // Get gas price
        let gasPrice = try await web3.eth.gasPrice()
        transaction.gasPrice = gasPrice

        // Sign and send
        let result = try await transaction.send(
            using: web3,
            password: "",
            account: fromAddress
        )

        print("✅ Transaction sent!")
        print("TX Hash: \(result.hash)")

        return result.hash
    }

    /// Sign a message
    /// - Parameters:
    ///   - message: Message to sign
    ///   - privateKey: Private key for signing
    /// - Returns: Signature
    public func signMessage(message: String, privateKey: String) throws -> String {
        guard let privateKeyData = Data.fromHex(privateKey) else {
            throw WalletError.invalidPrivateKey
        }

        guard let keystore = try? EthereumKeystoreV3(
            privateKey: privateKeyData,
            password: ""
        ) else {
            throw WalletError.keystoreCreationFailed
        }

        guard let address = keystore.addresses?.first else {
            throw WalletError.addressNotFound
        }

        let messageData = message.data(using: .utf8)!
        let signature = try Web3Signer.signPersonalMessage(
            messageData,
            keystore: keystore,
            account: address,
            password: ""
        )

        print("✍️  Message signed!")
        return signature.toHexString()
    }
}

/// Wallet error types
public enum WalletError: Error {
    case web3NotInitialized
    case keystoreCreationFailed
    case addressNotFound
    case privateKeyExtractionFailed
    case invalidPrivateKey
    case invalidAmount

    public var localizedDescription: String {
        switch self {
        case .web3NotInitialized:
            return "Web3 is not initialized"
        case .keystoreCreationFailed:
            return "Failed to create keystore"
        case .addressNotFound:
            return "Address not found in keystore"
        case .privateKeyExtractionFailed:
            return "Failed to extract private key"
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .invalidAmount:
            return "Invalid transaction amount"
        }
    }
}

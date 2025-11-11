package com.ethsold.wallet

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.web3j.crypto.*
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.DefaultBlockParameterName
import org.web3j.protocol.http.HttpService
import org.web3j.utils.Convert
import org.web3j.utils.Numeric
import java.math.BigDecimal
import java.math.BigInteger
import java.security.SecureRandom

/**
 * Ethereum wallet manager for Android.
 * Handles wallet creation, transaction signing, and blockchain interactions.
 */
class WalletManager(
    private val rpcUrl: String = "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
) {
    private val web3j: Web3j = Web3j.build(HttpService(rpcUrl))
    private val secureRandom = SecureRandom()

    /**
     * Data class representing a wallet.
     */
    data class Wallet(
        val address: String,
        val publicKey: String,
        val privateKey: String,
        val mnemonic: String? = null
    )

    /**
     * Data class for transaction details.
     */
    data class TransactionDetails(
        val to: String,
        val value: BigDecimal,
        val gasPrice: BigInteger,
        val gasLimit: BigInteger,
        val nonce: BigInteger,
        val data: String = ""
    )

    /**
     * Create a new Ethereum wallet with mnemonic phrase.
     */
    suspend fun createWallet(): Wallet = withContext(Dispatchers.IO) {
        val mnemonic = generateMnemonic()
        val credentials = createCredentialsFromMnemonic(mnemonic)

        Wallet(
            address = credentials.address,
            publicKey = credentials.ecKeyPair.publicKey.toString(16),
            privateKey = credentials.ecKeyPair.privateKey.toString(16),
            mnemonic = mnemonic
        )
    }

    /**
     * Import wallet from private key.
     */
    suspend fun importFromPrivateKey(privateKey: String): Wallet = withContext(Dispatchers.IO) {
        val credentials = Credentials.create(privateKey)

        Wallet(
            address = credentials.address,
            publicKey = credentials.ecKeyPair.publicKey.toString(16),
            privateKey = credentials.ecKeyPair.privateKey.toString(16)
        )
    }

    /**
     * Import wallet from mnemonic phrase.
     */
    suspend fun importFromMnemonic(mnemonic: String): Wallet = withContext(Dispatchers.IO) {
        val credentials = createCredentialsFromMnemonic(mnemonic)

        Wallet(
            address = credentials.address,
            publicKey = credentials.ecKeyPair.publicKey.toString(16),
            privateKey = credentials.ecKeyPair.privateKey.toString(16),
            mnemonic = mnemonic
        )
    }

    /**
     * Get account balance in ETH.
     */
    suspend fun getBalance(address: String): BigDecimal = withContext(Dispatchers.IO) {
        val balance = web3j.ethGetBalance(address, DefaultBlockParameterName.LATEST)
            .send()
            .balance

        Convert.fromWei(balance.toBigDecimal(), Convert.Unit.ETHER)
    }

    /**
     * Get current gas price.
     */
    suspend fun getGasPrice(): BigInteger = withContext(Dispatchers.IO) {
        web3j.ethGasPrice().send().gasPrice
    }

    /**
     * Get transaction count (nonce) for address.
     */
    suspend fun getTransactionCount(address: String): BigInteger = withContext(Dispatchers.IO) {
        web3j.ethGetTransactionCount(address, DefaultBlockParameterName.LATEST)
            .send()
            .transactionCount
    }

    /**
     * Send ETH transaction.
     */
    suspend fun sendTransaction(
        privateKey: String,
        details: TransactionDetails
    ): String = withContext(Dispatchers.IO) {
        val credentials = Credentials.create(privateKey)

        val rawTransaction = RawTransaction.createEtherTransaction(
            details.nonce,
            details.gasPrice,
            details.gasLimit,
            details.to,
            Convert.toWei(details.value, Convert.Unit.ETHER).toBigInteger()
        )

        val signedMessage = TransactionEncoder.signMessage(rawTransaction, credentials)
        val hexValue = Numeric.toHexString(signedMessage)

        web3j.ethSendRawTransaction(hexValue)
            .send()
            .transactionHash
    }

    /**
     * Sign message with private key.
     */
    suspend fun signMessage(privateKey: String, message: String): String = withContext(Dispatchers.IO) {
        val credentials = Credentials.create(privateKey)
        val messageBytes = message.toByteArray()

        val signature = Sign.signPrefixedMessage(messageBytes, credentials.ecKeyPair)

        Numeric.toHexString(
            signature.r + signature.s + byteArrayOf(signature.v.first())
        )
    }

    /**
     * Verify message signature.
     */
    suspend fun verifySignature(
        message: String,
        signature: String,
        expectedAddress: String
    ): Boolean = withContext(Dispatchers.IO) {
        try {
            val signatureBytes = Numeric.hexStringToByteArray(signature)
            val r = signatureBytes.copyOfRange(0, 32)
            val s = signatureBytes.copyOfRange(32, 64)
            val v = signatureBytes[64]

            val signatureData = Sign.SignatureData(v, r, s)
            val messageBytes = message.toByteArray()

            val publicKey = Sign.signedPrefixedMessageToKey(messageBytes, signatureData)
            val recoveredAddress = Keys.getAddress(publicKey)

            "0x$recoveredAddress".equals(expectedAddress, ignoreCase = true)
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Get current block number.
     */
    suspend fun getBlockNumber(): BigInteger = withContext(Dispatchers.IO) {
        web3j.ethBlockNumber().send().blockNumber
    }

    /**
     * Check if address is valid Ethereum address.
     */
    fun isValidAddress(address: String): Boolean {
        return try {
            WalletUtils.isValidAddress(address)
        } catch (e: Exception) {
            false
        }
    }

    // Private helper functions

    private fun generateMnemonic(): String {
        val entropy = ByteArray(16)
        secureRandom.nextBytes(entropy)
        return MnemonicUtils.generateMnemonic(entropy)
    }

    private fun createCredentialsFromMnemonic(mnemonic: String): Credentials {
        val seed = MnemonicUtils.generateSeed(mnemonic, "")
        val masterKeypair = Bip32ECKeyPair.generateKeyPair(seed)

        // Ethereum derivation path: m/44'/60'/0'/0/0
        val path = intArrayOf(
            44 or Bip32ECKeyPair.HARDENED_BIT,
            60 or Bip32ECKeyPair.HARDENED_BIT,
            0 or Bip32ECKeyPair.HARDENED_BIT,
            0,
            0
        )

        val derivedKeyPair = Bip32ECKeyPair.deriveKeyPair(masterKeypair, path)
        return Credentials.create(derivedKeyPair)
    }

    /**
     * Close Web3j connection.
     */
    fun close() {
        web3j.shutdown()
    }
}

package com.ethsold.blockchain

import cats.effect._
import cats.implicits._
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.DefaultBlockParameterName
import org.web3j.protocol.http.HttpService
import org.web3j.crypto._
import org.web3j.utils.Convert
import java.math.BigInteger
import scala.concurrent.{ExecutionContext, Future}
import scala.util.{Try, Success, Failure}

/**
 * Enterprise-grade Ethereum blockchain client using Scala.
 *
 * Features:
 * - Type-safe operations with Cats Effect
 * - Functional error handling
 * - Immutable data structures
 * - Actor-based concurrency support
 */
class BlockchainClient(rpcUrl: String)(implicit ec: ExecutionContext) {

  private val web3j: Web3j = Web3j.build(new HttpService(rpcUrl))

  /**
   * Account information.
   */
  case class Account(
    address: String,
    privateKey: String,
    publicKey: String
  )

  /**
   * Transaction details.
   */
  case class TransactionDetails(
    from: String,
    to: String,
    value: BigInteger,
    gasPrice: BigInteger,
    gasLimit: BigInteger,
    nonce: BigInteger,
    data: Option[String] = None
  )

  /**
   * Transaction result.
   */
  sealed trait TransactionResult
  case class TransactionSuccess(txHash: String) extends TransactionResult
  case class TransactionFailure(error: String) extends TransactionResult

  /**
   * Get current block number.
   */
  def getBlockNumber: IO[Either[String, BigInteger]] = IO {
    Try {
      web3j.ethBlockNumber().send().getBlockNumber
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Get account balance in Wei.
   */
  def getBalance(address: String): IO[Either[String, BigInteger]] = IO {
    Try {
      web3j.ethGetBalance(address, DefaultBlockParameterName.LATEST)
        .send()
        .getBalance
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Get account balance in ETH.
   */
  def getBalanceEth(address: String): IO[Either[String, BigDecimal]] = {
    getBalance(address).map {
      _.map(wei => Convert.fromWei(new java.math.BigDecimal(wei), Convert.Unit.ETHER))
    }
  }

  /**
   * Create new account.
   */
  def createAccount: IO[Account] = IO {
    val credentials = Credentials.create(Keys.createEcKeyPair())
    Account(
      address = credentials.getAddress,
      privateKey = credentials.getEcKeyPair.getPrivateKey.toString(16),
      publicKey = credentials.getEcKeyPair.getPublicKey.toString(16)
    )
  }

  /**
   * Import account from private key.
   */
  def importAccount(privateKey: String): IO[Either[String, Account]] = IO {
    Try {
      val credentials = Credentials.create(privateKey)
      Account(
        address = credentials.getAddress,
        privateKey = credentials.getEcKeyPair.getPrivateKey.toString(16),
        publicKey = credentials.getEcKeyPair.getPublicKey.toString(16)
      )
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Get transaction count (nonce).
   */
  def getTransactionCount(address: String): IO[Either[String, BigInteger]] = IO {
    Try {
      web3j.ethGetTransactionCount(address, DefaultBlockParameterName.LATEST)
        .send()
        .getTransactionCount
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Get current gas price.
   */
  def getGasPrice: IO[Either[String, BigInteger]] = IO {
    Try {
      web3j.ethGasPrice().send().getGasPrice
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Send transaction.
   */
  def sendTransaction(
    privateKey: String,
    details: TransactionDetails
  ): IO[TransactionResult] = IO {
    Try {
      val credentials = Credentials.create(privateKey)

      val rawTransaction = details.data match {
        case Some(data) =>
          RawTransaction.createTransaction(
            details.nonce,
            details.gasPrice,
            details.gasLimit,
            details.to,
            details.value,
            data
          )
        case None =>
          RawTransaction.createEtherTransaction(
            details.nonce,
            details.gasPrice,
            details.gasLimit,
            details.to,
            details.value
          )
      }

      val signedMessage = TransactionEncoder.signMessage(rawTransaction, credentials)
      val hexValue = org.web3j.utils.Numeric.toHexString(signedMessage)

      web3j.ethSendRawTransaction(hexValue)
        .send()
        .getTransactionHash
    } match {
      case Success(txHash) => TransactionSuccess(txHash)
      case Failure(error) => TransactionFailure(error.getMessage)
    }
  }

  /**
   * Sign message.
   */
  def signMessage(privateKey: String, message: String): IO[Either[String, String]] = IO {
    Try {
      val credentials = Credentials.create(privateKey)
      val messageBytes = message.getBytes()

      val signature = Sign.signPrefixedMessage(messageBytes, credentials.getEcKeyPair)

      org.web3j.utils.Numeric.toHexString(
        signature.getR ++ signature.getS ++ Array(signature.getV.head)
      )
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Call smart contract (read-only).
   */
  def callContract(
    contractAddress: String,
    data: String
  ): IO[Either[String, String]] = IO {
    Try {
      val transaction = org.web3j.protocol.core.methods.request.Transaction
        .createEthCallTransaction(null, contractAddress, data)

      web3j.ethCall(transaction, DefaultBlockParameterName.LATEST)
        .send()
        .getValue
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Estimate gas for transaction.
   */
  def estimateGas(
    from: String,
    to: String,
    value: BigInteger,
    data: Option[String] = None
  ): IO[Either[String, BigInteger]] = IO {
    Try {
      val transaction = data match {
        case Some(d) =>
          org.web3j.protocol.core.methods.request.Transaction
            .createFunctionCallTransaction(from, null, null, null, to, value, d)
        case None =>
          org.web3j.protocol.core.methods.request.Transaction
            .createEtherTransaction(from, null, null, null, to, value)
      }

      web3j.ethEstimateGas(transaction)
        .send()
        .getAmountUsed
    }.toEither.left.map(_.getMessage)
  }

  /**
   * Shutdown Web3j client.
   */
  def shutdown(): IO[Unit] = IO {
    web3j.shutdown()
  }
}

/**
 * Companion object with factory methods.
 */
object BlockchainClient {
  def apply(rpcUrl: String)(implicit ec: ExecutionContext): BlockchainClient =
    new BlockchainClient(rpcUrl)

  def mainnet(apiKey: String)(implicit ec: ExecutionContext): BlockchainClient =
    new BlockchainClient(s"https://eth-mainnet.g.alchemy.com/v2/$apiKey")

  def sepolia(apiKey: String)(implicit ec: ExecutionContext): BlockchainClient =
    new BlockchainClient(s"https://eth-sepolia.g.alchemy.com/v2/$apiKey")

  def local(implicit ec: ExecutionContext): BlockchainClient =
    new BlockchainClient("http://localhost:8545")
}

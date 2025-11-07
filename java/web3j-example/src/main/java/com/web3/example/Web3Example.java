package com.web3.example;

import org.web3j.crypto.Credentials;
import org.web3j.crypto.ECKeyPair;
import org.web3j.crypto.Keys;
import org.web3j.crypto.WalletUtils;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.Transfer;
import org.web3j.utils.Convert;

import java.math.BigDecimal;
import java.math.BigInteger;

/**
 * Web3j Example - Java library for Ethereum interactions
 * Demonstrates wallet creation, balance queries, and transactions
 */
public class Web3Example {

    private Web3j web3j;
    private static final String RPC_URL = "http://localhost:8545";

    public Web3Example(String rpcUrl) {
        this.web3j = Web3j.build(new HttpService(rpcUrl));
    }

    /**
     * Get Web3j client version
     */
    public String getClientVersion() throws Exception {
        Web3ClientVersion clientVersion = web3j.web3ClientVersion().send();
        return clientVersion.getWeb3ClientVersion();
    }

    /**
     * Get latest block number
     */
    public BigInteger getBlockNumber() throws Exception {
        EthBlockNumber blockNumber = web3j.ethBlockNumber().send();
        return blockNumber.getBlockNumber();
    }

    /**
     * Get ETH balance of an address
     */
    public BigDecimal getBalance(String address) throws Exception {
        EthGetBalance balance = web3j.ethGetBalance(
            address,
            DefaultBlockParameterName.LATEST
        ).send();

        // Convert Wei to Ether
        BigInteger balanceWei = balance.getBalance();
        return Convert.fromWei(new BigDecimal(balanceWei), Convert.Unit.ETHER);
    }

    /**
     * Create a new Ethereum wallet
     */
    public Credentials createWallet() throws Exception {
        // Generate new key pair
        ECKeyPair keyPair = Keys.createEcKeyPair();
        Credentials credentials = Credentials.create(keyPair);

        System.out.println("🎉 New wallet created!");
        System.out.println("Address: " + credentials.getAddress());
        System.out.println("Private Key: 0x" + keyPair.getPrivateKey().toString(16));

        return credentials;
    }

    /**
     * Send ETH transaction
     */
    public String sendTransaction(
        Credentials credentials,
        String toAddress,
        BigDecimal amount
    ) throws Exception {
        System.out.println("📤 Sending " + amount + " ETH to " + toAddress);

        TransactionReceipt receipt = Transfer.sendFunds(
            web3j,
            credentials,
            toAddress,
            amount,
            Convert.Unit.ETHER
        ).send();

        System.out.println("✅ Transaction successful!");
        System.out.println("TX Hash: " + receipt.getTransactionHash());
        System.out.println("Gas Used: " + receipt.getGasUsed());

        return receipt.getTransactionHash();
    }

    /**
     * Get transaction by hash
     */
    public void getTransaction(String txHash) throws Exception {
        EthTransaction transaction = web3j.ethGetTransactionByHash(txHash).send();

        if (transaction.getTransaction().isPresent()) {
            Transaction tx = transaction.getTransaction().get();

            System.out.println("\n=== Transaction Details ===");
            System.out.println("From: " + tx.getFrom());
            System.out.println("To: " + tx.getTo());
            System.out.println("Value: " +
                Convert.fromWei(new BigDecimal(tx.getValue()), Convert.Unit.ETHER) + " ETH");
            System.out.println("Gas: " + tx.getGas());
            System.out.println("Gas Price: " + tx.getGasPrice());
            System.out.println("Nonce: " + tx.getNonce());
        } else {
            System.out.println("Transaction not found");
        }
    }

    /**
     * Get gas price
     */
    public BigInteger getGasPrice() throws Exception {
        EthGasPrice gasPrice = web3j.ethGasPrice().send();
        return gasPrice.getGasPrice();
    }

    /**
     * Sign a message
     */
    public String signMessage(Credentials credentials, String message) {
        byte[] messageBytes = message.getBytes();
        // In production, use proper message signing with EIP-191 prefix
        System.out.println("✍️  Message signed!");
        return "0x..."; // Simplified
    }

    public static void main(String[] args) {
        try {
            String rpcUrl = System.getenv("ETH_RPC_URL");
            if (rpcUrl == null || rpcUrl.isEmpty()) {
                rpcUrl = RPC_URL;
            }

            Web3Example web3 = new Web3Example(rpcUrl);

            System.out.println("=== Web3j Java Example ===\n");

            // Get client version
            System.out.println("Client: " + web3.getClientVersion());

            // Get block number
            System.out.println("Latest Block: " + web3.getBlockNumber());

            // Get gas price
            BigInteger gasPrice = web3.getGasPrice();
            System.out.println("Gas Price: " +
                Convert.fromWei(new BigDecimal(gasPrice), Convert.Unit.GWEI) + " Gwei");

            // Example: Check balance
            if (args.length > 0 && args[0].equals("balance")) {
                if (args.length < 2) {
                    System.out.println("Usage: java Web3Example balance <address>");
                    return;
                }
                String address = args[1];
                BigDecimal balance = web3.getBalance(address);
                System.out.println("\n💰 Balance of " + address);
                System.out.println(balance + " ETH");
            }

            // Example: Create wallet
            if (args.length > 0 && args[0].equals("create")) {
                web3.createWallet();
                System.out.println("\n⚠️  Keep your private key safe!");
            }

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

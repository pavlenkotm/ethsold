# ☕ Java Web3j Example

Enterprise-grade Ethereum integration using Web3j - the most popular Java library for blockchain interactions.

## 📋 Overview

Web3j is a lightweight, reactive Java and Android library for working with Ethereum. This example demonstrates:
- Connecting to Ethereum nodes
- Wallet creation and management
- Balance queries
- Transaction sending
- Smart contract interactions

## ✨ Features

- 🔌 **RPC Connection** - Connect to any Ethereum node
- 💼 **Wallet Management** - Create and manage wallets
- 💰 **Balance Queries** - Check ETH and token balances
- 📤 **Transactions** - Send ETH securely
- 📜 **Smart Contracts** - Deploy and interact with contracts
- 🏢 **Enterprise Ready** - Production-grade library

## 🚀 Quick Start

### Prerequisites

- Java >= 17
- Maven >= 3.8

### Build

```bash
cd java/web3j-example
mvn clean package
```

### Run

**Check balance:**
```bash
java -cp target/web3j-example-1.0.0.jar \
  com.web3.example.Web3Example balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

**Create wallet:**
```bash
java -cp target/web3j-example-1.0.0.jar \
  com.web3.example.Web3Example create
```

### Environment Variables

```bash
export ETH_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY"
```

## 📁 Project Structure

```
web3j-example/
├── pom.xml                        # Maven configuration
├── src/
│   └── main/
│       └── java/
│           └── com/web3/example/
│               └── Web3Example.java
└── README.md
```

## 🔑 Core Functionality

### Initialize Web3j

```java
Web3j web3j = Web3j.build(new HttpService("http://localhost:8545"));

// Get client version
Web3ClientVersion clientVersion = web3j.web3ClientVersion().send();
System.out.println(clientVersion.getWeb3ClientVersion());
```

### Create Wallet

```java
ECKeyPair keyPair = Keys.createEcKeyPair();
Credentials credentials = Credentials.create(keyPair);

String address = credentials.getAddress();
BigInteger privateKey = keyPair.getPrivateKey();
```

### Get Balance

```java
EthGetBalance balance = web3j.ethGetBalance(
    address,
    DefaultBlockParameterName.LATEST
).send();

BigDecimal eth = Convert.fromWei(
    new BigDecimal(balance.getBalance()),
    Convert.Unit.ETHER
);
```

### Send Transaction

```java
TransactionReceipt receipt = Transfer.sendFunds(
    web3j,
    credentials,
    toAddress,
    BigDecimal.ONE,  // 1 ETH
    Convert.Unit.ETHER
).send();
```

### Smart Contract Interaction

```java
// Load contract
YourContract contract = YourContract.load(
    contractAddress,
    web3j,
    credentials,
    gasPrice,
    gasLimit
);

// Call function
BigInteger result = contract.getValue().send();

// Send transaction
TransactionReceipt receipt = contract.setValue(
    new BigInteger("42")
).send();
```

## 📦 Dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| web3j-core | 4.10.3 | Ethereum library |
| slf4j | 2.0.9 | Logging |
| junit-jupiter | 5.10.0 | Testing |

## 🧪 Testing

```bash
mvn test
```

## 🔒 Security Best Practices

- ✅ Never hardcode private keys
- ✅ Use secure key storage (HSM, KeyStore)
- ✅ Validate all addresses
- ✅ Implement proper error handling
- ✅ Use gas estimation
- ✅ Test on testnets first

## 💡 Advanced Features

### Contract Generation from ABI

```bash
# Generate Java wrapper from Solidity contract
web3j generate solidity \
  -a path/to/contract.abi \
  -b path/to/contract.bin \
  -o src/main/java \
  -p com.example.contracts
```

### Event Filtering

```java
EthFilter filter = new EthFilter(
    DefaultBlockParameterName.EARLIEST,
    DefaultBlockParameterName.LATEST,
    contractAddress
);

web3j.ethLogFlowable(filter).subscribe(log -> {
    // Process event
    System.out.println("Event: " + log.getData());
});
```

### Gas Optimization

```java
// Estimate gas
EthEstimateGas estimateGas = web3j.ethEstimateGas(transaction).send();
BigInteger gasLimit = estimateGas.getAmountUsed();

// Get current gas price
EthGasPrice gasPrice = web3j.ethGasPrice().send();
```

## 📚 Resources

- [Web3j Documentation](https://docs.web3j.io/)
- [Ethereum Java](https://ethereum.org/en/developers/docs/programming-languages/java/)
- [Web3j GitHub](https://github.com/web3j/web3j)
- [Web3j CLI](https://docs.web3j.io/4.8.7/command_line_tools/)

## 🚀 Production Checklist

- [ ] Use connection pooling
- [ ] Implement retry logic
- [ ] Add proper logging
- [ ] Monitor gas prices
- [ ] Handle nonce management
- [ ] Implement circuit breakers
- [ ] Use async operations for scalability

## 📝 License

MIT License

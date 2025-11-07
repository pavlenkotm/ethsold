# 🍎 Swift Web3 Wallet SDK

Native iOS/macOS wallet SDK for Ethereum using web3swift library. Build decentralized applications for Apple platforms.

## 📋 Overview

This Swift package provides:
- Wallet creation and management
- Balance queries
- Transaction sending
- Message signing
- iOS/macOS compatibility

## ✨ Features

- 📱 **iOS/macOS Native** - Swift Package Manager support
- 🔐 **Secure** - Uses Apple's Keychain for key storage
- ⚡ **Async/Await** - Modern Swift concurrency
- 🎨 **SwiftUI Ready** - Easy integration with SwiftUI apps
- 🔌 **Web3swift** - Built on production-tested library

## 🚀 Quick Start

### Prerequisites

- Xcode 14+
- iOS 15+ / macOS 12+
- Swift 5.9+

### Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/your-repo/Web3WalletSDK.git",
        from: "1.0.0"
    )
]
```

Or add via Xcode:
1. File → Add Packages
2. Enter repository URL
3. Select version

### Usage

```swift
import Web3WalletSDK

// Initialize wallet manager
let walletManager = WalletManager(
    rpcURL: "https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY"
)

// Create wallet
let (address, privateKey) = try walletManager.createWallet()
print("Address: \(address)")

// Get balance
Task {
    let balance = try await walletManager.getBalance(address: address)
    print("Balance: \(balance) ETH")
}

// Send transaction
Task {
    let txHash = try await walletManager.sendTransaction(
        privateKey: privateKey,
        toAddress: "0x...",
        amount: "0.1"  // ETH
    )
    print("TX: \(txHash)")
}

// Sign message
let signature = try walletManager.signMessage(
    message: "Hello Web3",
    privateKey: privateKey
)
```

## 📁 Project Structure

```
wallet-sdk/
├── Package.swift              # SPM configuration
├── Sources/
│   └── Web3WalletSDK/
│       ├── WalletManager.swift
│       └── Models/
└── Tests/
    └── Web3WalletSDKTests/
```

## 🎯 SwiftUI Example

```swift
import SwiftUI
import Web3WalletSDK

struct WalletView: View {
    @StateObject var viewModel = WalletViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Address: \(viewModel.address)")
                .font(.caption)

            Text("\(viewModel.balance) ETH")
                .font(.title)
                .bold()

            Button("Send Transaction") {
                Task {
                    await viewModel.sendETH(
                        to: "0x...",
                        amount: "0.1"
                    )
                }
            }
        }
        .task {
            await viewModel.loadBalance()
        }
    }
}

@MainActor
class WalletViewModel: ObservableObject {
    @Published var address = ""
    @Published var balance = "0"

    private let walletManager: WalletManager

    init() {
        self.walletManager = WalletManager(rpcURL: "...")
    }

    func loadBalance() async {
        do {
            balance = try await walletManager.getBalance(address: address)
        } catch {
            print("Error: \(error)")
        }
    }

    func sendETH(to: String, amount: String) async {
        // Implementation
    }
}
```

## 🔒 Security Best Practices

### Keychain Storage

```swift
import Security

func savePrivateKey(_ key: String, for account: String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: key.data(using: .utf8)!,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]

    SecItemAdd(query as CFDictionary, nil)
}

func loadPrivateKey(for account: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecReturnData as String: true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess,
       let data = result as? Data,
       let key = String(data: data, encoding: .utf8) {
        return key
    }

    return nil
}
```

### Biometric Authentication

```swift
import LocalAuthentication

func authenticateUser() async throws -> Bool {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: &error
    ) else {
        throw WalletError.biometricsUnavailable
    }

    return try await context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Authenticate to access wallet"
    )
}
```

## 📦 Dependencies

- **web3swift** - Core Web3 functionality
- **BigInt** - Large number operations
- **CryptoSwift** - Cryptographic operations

## 🧪 Testing

```bash
swift test
```

```swift
import XCTest
@testable import Web3WalletSDK

final class WalletManagerTests: XCTestCase {
    var walletManager: WalletManager!

    override func setUp() {
        walletManager = WalletManager()
    }

    func testWalletCreation() throws {
        let (address, privateKey) = try walletManager.createWallet()

        XCTAssertFalse(address.isEmpty)
        XCTAssertFalse(privateKey.isEmpty)
        XCTAssertTrue(address.hasPrefix("0x"))
    }

    func testMessageSigning() throws {
        let (_, privateKey) = try walletManager.createWallet()
        let signature = try walletManager.signMessage(
            message: "Test",
            privateKey: privateKey
        )

        XCTAssertFalse(signature.isEmpty)
    }
}
```

## 📚 Resources

- [web3swift Documentation](https://github.com/web3swift-team/web3swift)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Swift Package Manager](https://swift.org/package-manager/)
- [iOS Security Best Practices](https://developer.apple.com/documentation/security)

## 🚀 Deployment

### TestFlight

1. Archive your app in Xcode
2. Upload to App Store Connect
3. Submit for TestFlight beta testing

### App Store

Ensure compliance with:
- App Store Review Guidelines
- Cryptocurrency guidelines
- Export compliance for encryption

## 📝 License

MIT License

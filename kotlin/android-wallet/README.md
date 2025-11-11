# Kotlin Android Ethereum Wallet

Modern Android Ethereum wallet built with Kotlin, Jetpack Compose, and Web3j.

## Features

- **Modern UI** - Built with Jetpack Compose
- **Secure Storage** - Encrypted SharedPreferences and Keystore
- **Biometric Auth** - Fingerprint/Face unlock support
- **HD Wallets** - BIP-39/BIP-44 mnemonic phrase generation
- **Transaction Signing** - Local transaction signing with Web3j
- **Multi-chain** - Support for Ethereum mainnet and testnets
- **QR Codes** - Scan and generate QR codes for addresses
- **Coroutines** - Async operations with Kotlin Coroutines
- **Material Design 3** - Latest Material Design components

## Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- Android SDK 26+ (Oreo or later)
- Kotlin 1.9.0+
- Gradle 8.1+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/pavlenkotm/ethsold.git
cd ethsold/kotlin/android-wallet
```

2. Open in Android Studio

3. Add your Ethereum RPC endpoint in `WalletManager.kt`:
```kotlin
private val rpcUrl: String = "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
```

4. Build and run:
```bash
./gradlew assembleDebug
./gradlew installDebug
```

## Usage

### Create Wallet Manager

```kotlin
val walletManager = WalletManager(
    rpcUrl = "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
)
```

### Create New Wallet

```kotlin
lifecycleScope.launch {
    val wallet = walletManager.createWallet()

    println("Address: ${wallet.address}")
    println("Mnemonic: ${wallet.mnemonic}")

    // IMPORTANT: Securely store the mnemonic!
    secureStorage.save("mnemonic", wallet.mnemonic)
}
```

### Import Wallet

```kotlin
// From mnemonic
lifecycleScope.launch {
    val wallet = walletManager.importFromMnemonic(
        "word1 word2 word3 ... word12"
    )
}

// From private key
lifecycleScope.launch {
    val wallet = walletManager.importFromPrivateKey(
        "0x1234567890abcdef..."
    )
}
```

### Get Balance

```kotlin
lifecycleScope.launch {
    val balance = walletManager.getBalance("0xYourAddress")
    println("Balance: $balance ETH")
}
```

### Send Transaction

```kotlin
lifecycleScope.launch {
    val gasPrice = walletManager.getGasPrice()
    val nonce = walletManager.getTransactionCount(senderAddress)

    val details = WalletManager.TransactionDetails(
        to = "0xRecipientAddress",
        value = BigDecimal("0.1"), // 0.1 ETH
        gasPrice = gasPrice,
        gasLimit = BigInteger.valueOf(21000),
        nonce = nonce
    )

    val txHash = walletManager.sendTransaction(privateKey, details)
    println("Transaction hash: $txHash")
}
```

### Sign Message

```kotlin
lifecycleScope.launch {
    val signature = walletManager.signMessage(
        privateKey = privateKey,
        message = "Hello, Ethereum!"
    )

    // Verify signature
    val isValid = walletManager.verifySignature(
        message = "Hello, Ethereum!",
        signature = signature,
        expectedAddress = address
    )
}
```

## Architecture

```
app/
├── ui/                      # Compose UI screens
│   ├── screens/            # Main screens
│   ├── components/         # Reusable components
│   └── theme/              # Material Design theme
├── data/                   # Data layer
│   ├── repository/         # Repository pattern
│   ├── local/              # Local storage
│   └── remote/             # Network calls
├── domain/                 # Business logic
│   ├── model/              # Domain models
│   └── usecase/            # Use cases
├── di/                     # Dependency injection
└── util/                   # Utilities
```

## Security Features

### Encrypted Storage

```kotlin
val encryptedPrefs = EncryptedSharedPreferences.create(
    context,
    "wallet_prefs",
    MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build(),
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
```

### Biometric Authentication

```kotlin
val biometricPrompt = BiometricPrompt(
    this,
    executor,
    object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
            // Access wallet
        }
    }
)

biometricPrompt.authenticate(promptInfo)
```

## Testing

```bash
# Unit tests
./gradlew test

# Instrumented tests
./gradlew connectedAndroidTest

# UI tests
./gradlew connectedDebugAndroidTest
```

## ProGuard Rules

Add to `proguard-rules.pro`:

```proguard
# Web3j
-keep class org.web3j.** { *; }
-dontwarn org.web3j.**

# Bouncy Castle
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**
```

## Permissions

Required permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" /> <!-- For QR scanning -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

## Why Kotlin for Android Wallets?

- **Null Safety** - Eliminates NullPointerException
- **Coroutines** - Elegant async programming
- **Modern** - Latest Android development best practices
- **Type Safety** - Compile-time error detection
- **Jetpack** - First-class Jetpack library support
- **Interop** - Seamless Java interoperability

## Security Best Practices

1. **Never log private keys or mnemonics**
2. **Use encrypted storage for sensitive data**
3. **Implement biometric authentication**
4. **Validate all user inputs**
5. **Use ProGuard/R8 for code obfuscation**
6. **Implement root detection**
7. **Use certificate pinning for network calls**

## Screenshots

[Add screenshots here]

## License

MIT License - see LICENSE file for details

## Resources

- [Web3j Documentation](https://docs.web3j.io/)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Kotlin Coroutines](https://kotlinlang.org/docs/coroutines-overview.html)
- [Android Security](https://developer.android.com/training/articles/security-tips)
- [BIP-39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- [BIP-44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)

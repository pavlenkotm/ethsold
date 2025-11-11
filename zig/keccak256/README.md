# Zig Ethereum Keccak256 Implementation

High-performance Keccak256 hash implementation and Ethereum address utilities written in Zig.

## Features

- **Keccak256 Hashing** - Fast cryptographic hash function used in Ethereum
- **Address Generation** - Generate Ethereum addresses from public keys
- **EIP-55 Checksum** - Mixed-case address checksums for error detection
- **Zero Dependencies** - Uses only Zig standard library
- **Type Safety** - Leverages Zig's compile-time safety guarantees
- **Performance** - Native compiled code with optimal performance

## Prerequisites

- Zig 0.11.0 or later

## Installation

```bash
# Download Zig from https://ziglang.org/download/
curl -LO https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz
tar -xf zig-linux-x86_64-0.11.0.tar.xz
export PATH=$PATH:$(pwd)/zig-linux-x86_64-0.11.0
```

## Building

```bash
# Build the library and executable
zig build

# Build with optimizations
zig build -Doptimize=ReleaseFast

# Run the example
zig build run
```

## Testing

```bash
# Run all tests
zig build test

# Run with verbose output
zig test src/main.zig
```

## Usage

### Basic Keccak256 Hash

```zig
const Keccak256 = @import("main.zig").Keccak256;

var hash: [32]u8 = undefined;
Keccak256.hash("Hello, Ethereum!", &hash);
// hash now contains the Keccak256 digest
```

### Generate Ethereum Address

```zig
const EthAddress = @import("main.zig").EthAddress;

// 64-byte uncompressed public key (without 0x04 prefix)
const pub_key: [64]u8 = ...;
const address = try EthAddress.fromPublicKey(allocator, &pub_key);
defer allocator.free(address);
// address: "0x..."
```

### EIP-55 Checksum Address

```zig
const address = "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed";
const checksum = try EthAddress.toChecksumAddress(allocator, address);
defer allocator.free(checksum);
// checksum: "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"

// Verify checksum
const is_valid = Keccak256.verifyAddressChecksum(checksum);
```

## API Reference

### Keccak256

```zig
pub const Keccak256 = struct {
    /// Compute Keccak256 hash
    pub fn hash(input: []const u8, output: *[32]u8) void;

    /// Compute hash and return as hex string
    pub fn hashToHex(allocator: Allocator, input: []const u8) ![]u8;

    /// Verify EIP-55 address checksum
    pub fn verifyAddressChecksum(address: []const u8) bool;
};
```

### EthAddress

```zig
pub const EthAddress = struct {
    /// Generate address from public key
    pub fn fromPublicKey(allocator: Allocator, pub_key: []const u8) ![]u8;

    /// Apply EIP-55 checksum
    pub fn toChecksumAddress(allocator: Allocator, address: []const u8) ![]u8;
};
```

## Why Zig?

Zig is an excellent choice for blockchain/crypto operations:

- **Performance** - Compiles to native code, no runtime overhead
- **Safety** - Compile-time bounds checking and null safety
- **Simplicity** - No hidden control flow or allocations
- **Interop** - Easy C interoperability for existing crypto libraries
- **Cross-compilation** - Built-in cross-compilation to any target

## Performance

Zig's compile-time optimizations and zero-cost abstractions provide performance comparable to C/C++ while maintaining safety:

- Release builds use LLVM optimizations
- Inline assembly support for critical paths
- Manual memory management for minimal overhead

## Examples

Run the example program:

```bash
zig build run
```

Output:
```
=== Zig Ethereum Keccak256 Implementation ===

Message: Hello, Ethereum!
Keccak256 Hash: 0x...

Public Key: 0x04e68acfc...
Ethereum Address: 0x...

Checksum Address: 0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed
Checksum Valid: true

✓ All operations completed successfully!
```

## License

MIT License - see LICENSE file for details

## Resources

- [Zig Language](https://ziglang.org/)
- [Keccak256 Algorithm](https://keccak.team/)
- [EIP-55: Mixed-case checksum](https://eips.ethereum.org/EIPS/eip-55)
- [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)

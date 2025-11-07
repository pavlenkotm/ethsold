/**
 * AssemblyScript WASM for Blockchain
 * Compile TypeScript to WebAssembly for high-performance operations
 */

// Keccak256 hash (simplified implementation)
export function keccak256(data: Uint8Array): Uint8Array {
  // In production, use a full implementation like as-crypto
  const result = new Uint8Array(32);

  // Simplified hash (NOT cryptographically secure - for demo only)
  for (let i = 0; i < data.length; i++) {
    result[i % 32] ^= data[i];
  }

  return result;
}

// Convert hex string to bytes
export function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);

  for (let i = 0; i < hex.length; i += 2) {
    const byte = parseInt(hex.substr(i, 2), 16);
    bytes[i / 2] = byte;
  }

  return bytes;
}

// Convert bytes to hex string
export function bytesToHex(bytes: Uint8Array): string {
  let hex = "";

  for (let i = 0; i < bytes.length; i++) {
    const byte = bytes[i];
    hex += (byte < 16 ? "0" : "") + byte.toString(16);
  }

  return hex;
}

// Ethereum address validation
export function isValidAddress(address: string): bool {
  // Must start with 0x
  if (!address.startsWith("0x")) {
    return false;
  }

  // Must be 42 characters (0x + 40 hex chars)
  if (address.length != 42) {
    return false;
  }

  // All characters after 0x must be hex
  for (let i = 2; i < address.length; i++) {
    const char = address.charCodeAt(i);
    const isDigit = char >= 48 && char <= 57;  // 0-9
    const isLowerHex = char >= 97 && char <= 102;  // a-f
    const isUpperHex = char >= 65 && char <= 70;  // A-F

    if (!isDigit && !isLowerHex && !isUpperHex) {
      return false;
    }
  }

  return true;
}

// BigInt addition (for large numbers in blockchain)
export function addBigInt(a: u64, b: u64): u64 {
  return a + b;
}

// BigInt multiplication
export function mulBigInt(a: u64, b: u64): u64 {
  return a * b;
}

// Wei to Ether conversion
// 1 ETH = 10^18 Wei
export function weiToEth(wei: u64): f64 {
  return f64(wei) / 1000000000000000000.0;
}

// Ether to Wei conversion
export function ethToWei(eth: f64): u64 {
  return u64(eth * 1000000000000000000.0);
}

// Calculate gas cost
export function calculateGasCost(gasUsed: u64, gasPrice: u64): u64 {
  return gasUsed * gasPrice;
}

// Merkle proof verification (simplified)
export function verifyMerkleProof(
  leaf: Uint8Array,
  proof: Uint8Array[],
  root: Uint8Array
): bool {
  let computedHash = leaf;

  for (let i = 0; i < proof.length; i++) {
    const proofElement = proof[i];

    // Concatenate and hash
    const combined = new Uint8Array(computedHash.length + proofElement.length);
    combined.set(computedHash, 0);
    combined.set(proofElement, computedHash.length);

    computedHash = keccak256(combined);
  }

  // Compare with root
  if (computedHash.length != root.length) {
    return false;
  }

  for (let i = 0; i < computedHash.length; i++) {
    if (computedHash[i] != root[i]) {
      return false;
    }
  }

  return true;
}

// RLP encoding (simplified)
export class RLPEncoder {
  static encodeLength(length: u32, offset: u8): Uint8Array {
    if (length < 56) {
      return Uint8Array.wrap([offset + length]);
    } else {
      const lengthBytes = this.toBytes(length);
      const result = new Uint8Array(1 + lengthBytes.length);
      result[0] = offset + 55 + lengthBytes.length;
      result.set(lengthBytes, 1);
      return result;
    }
  }

  static toBytes(value: u32): Uint8Array {
    const bytes: u8[] = [];
    let temp = value;

    while (temp > 0) {
      bytes.unshift(<u8>(temp & 0xff));
      temp >>= 8;
    }

    return Uint8Array.wrap(bytes);
  }
}

// Benchmark function
export function benchmark(iterations: u32): u64 {
  const start = Date.now();

  for (let i: u32 = 0; i < iterations; i++) {
    const data = new Uint8Array(32);
    data[0] = <u8>i;
    keccak256(data);
  }

  return Date.now() - start;
}

## Ethereum Keccak256 implementation in Nim
## High-performance hashing for blockchain operations

import std/[strutils, sequtils, strformat]
import nimcrypto/[keccak, hash]

type
  EthAddress* = distinct string
  Hash256* = MDigest[256]

proc keccak256*(data: string): Hash256 =
  ## Compute Keccak256 hash of input string
  keccak256.digest(data)

proc keccak256*(data: openArray[byte]): Hash256 =
  ## Compute Keccak256 hash of byte array
  keccak256.digest(data)

proc toHex*(hash: Hash256): string =
  ## Convert hash to hexadecimal string
  "0x" & hash.data.mapIt(it.toHex(2)).join("").toLowerAscii()

proc addressFromPublicKey*(pubKey: string): EthAddress =
  ## Generate Ethereum address from public key
  ## Takes 64-byte public key (without 0x04 prefix)
  let pubKeyBytes = pubKey.parseHexStr()
  let hash = keccak256(pubKeyBytes)

  # Take last 20 bytes
  var addressBytes: array[20, byte]
  for i in 0..<20:
    addressBytes[i] = hash.data[12 + i]

  let addressHex = addressBytes.mapIt(it.toHex(2)).join("").toLowerAscii()
  result = EthAddress("0x" & addressHex)

proc checksumAddress*(address: string): string =
  ## Apply EIP-55 checksum encoding to address
  var addrLower = address[2..^1].toLowerAscii()
  let hash = keccak256(addrLower)

  var result = "0x"
  for i, c in addrLower:
    let hashByte = hash.data[i div 2]
    let nibble = if i mod 2 == 0: hashByte shr 4 else: hashByte and 0x0F

    if c >= 'a' and c <= 'f' and nibble >= 8:
      result &= c.toUpperAscii()
    else:
      result &= c

  return result

proc verifyChecksum*(address: string): bool =
  ## Verify EIP-55 checksum of address
  if address.len != 42 or not address.startsWith("0x"):
    return false

  let checksummed = checksumAddress(address)
  return address == checksummed

proc signatureHash*(functionSignature: string): string =
  ## Compute function signature hash (first 4 bytes)
  let hash = keccak256(functionSignature)
  "0x" & hash.data[0..3].mapIt(it.toHex(2)).join("").toLowerAscii()

# Example usage and tests
when isMainModule:
  echo "=== Nim Ethereum Keccak256 Implementation ==="
  echo ""

  # Test 1: Hash a string
  let message = "Hello, Ethereum!"
  let hash = keccak256(message)
  echo &"Message: {message}"
  echo &"Keccak256 Hash: {hash.toHex()}"
  echo ""

  # Test 2: Generate address from public key
  let pubKey = "e68acfc0253a10620dff706b0a1b1f1f5833ea3beb3bde2250d5f271f3563606672ebc45e0b7ea2e816ecb70ca03137b1c9476eec63d4632e990020b7b6fba39"
  let address = addressFromPublicKey(pubKey)
  echo &"Public Key: 0x{pubKey}"
  echo &"Ethereum Address: {address.string}"
  echo ""

  # Test 3: EIP-55 Checksum
  let testAddr = "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed"
  let checksum = checksumAddress(testAddr)
  let isValid = verifyChecksum(checksum)
  echo &"Original Address: {testAddr}"
  echo &"Checksum Address: {checksum}"
  echo &"Checksum Valid: {isValid}"
  echo ""

  # Test 4: Function signature
  let funcSig = "transfer(address,uint256)"
  let sigHash = signatureHash(funcSig)
  echo &"Function Signature: {funcSig}"
  echo &"Signature Hash: {sigHash}"
  echo ""

  echo "✓ All operations completed successfully!"

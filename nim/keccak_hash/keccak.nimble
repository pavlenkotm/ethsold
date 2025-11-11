# Package
version       = "0.1.0"
author        = "EthSold Contributors"
description   = "Ethereum Keccak256 implementation in Nim"
license       = "MIT"
srcDir        = "."
bin           = @["keccak"]

# Dependencies
requires "nim >= 2.0.0"
requires "nimcrypto >= 0.6.0"

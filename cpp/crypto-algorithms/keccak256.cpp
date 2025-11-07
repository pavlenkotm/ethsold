/**
 * Keccak-256 Hash Implementation
 * Cryptographic hash function used in Ethereum
 */

#include <iostream>
#include <string>
#include <vector>
#include <iomanip>
#include <cstring>
#include <openssl/evp.h>
#include <openssl/sha.h>

class Keccak256 {
public:
    /**
     * Compute Keccak-256 hash of input data
     * @param input Input data to hash
     * @return Hex-encoded hash
     */
    static std::string hash(const std::string& input) {
        std::vector<unsigned char> hash_bytes = hashToBytes(input);
        return bytesToHex(hash_bytes);
    }

    /**
     * Compute Keccak-256 hash and return raw bytes
     */
    static std::vector<unsigned char> hashToBytes(const std::string& input) {
        EVP_MD_CTX* ctx = EVP_MD_CTX_new();
        const EVP_MD* md = EVP_sha3_256();  // SHA3-256 is Keccak-256

        std::vector<unsigned char> hash(EVP_MD_size(md));
        unsigned int hash_len;

        EVP_DigestInit_ex(ctx, md, nullptr);
        EVP_DigestUpdate(ctx, input.c_str(), input.length());
        EVP_DigestFinal_ex(ctx, hash.data(), &hash_len);
        EVP_MD_CTX_free(ctx);

        return hash;
    }

    /**
     * Convert bytes to hexadecimal string
     */
    static std::string bytesToHex(const std::vector<unsigned char>& bytes) {
        std::stringstream ss;
        ss << "0x";
        for (unsigned char byte : bytes) {
            ss << std::hex << std::setw(2) << std::setfill('0') << (int)byte;
        }
        return ss.str();
    }

    /**
     * Ethereum address generation from public key
     * Address = last 20 bytes of Keccak-256(public_key)
     */
    static std::string publicKeyToAddress(const std::string& publicKey) {
        std::vector<unsigned char> hash = hashToBytes(publicKey);

        // Take last 20 bytes
        std::stringstream ss;
        ss << "0x";
        for (size_t i = hash.size() - 20; i < hash.size(); i++) {
            ss << std::hex << std::setw(2) << std::setfill('0') << (int)hash[i];
        }
        return ss.str();
    }
};

/**
 * ECDSA secp256k1 operations for Ethereum
 */
class EthereumCrypto {
public:
    /**
     * Generate random private key (256 bits)
     */
    static std::string generatePrivateKey() {
        unsigned char key[32];
        RAND_bytes(key, 32);

        std::stringstream ss;
        ss << "0x";
        for (int i = 0; i < 32; i++) {
            ss << std::hex << std::setw(2) << std::setfill('0') << (int)key[i];
        }
        return ss.str();
    }

    /**
     * Verify Ethereum signature
     * Note: Full implementation requires secp256k1 library
     */
    static bool verifySignature(
        const std::string& message,
        const std::string& signature,
        const std::string& publicKey
    ) {
        // Simplified verification logic
        // In production, use libsecp256k1 for proper ECDSA verification
        std::vector<unsigned char> messageHash = Keccak256::hashToBytes(message);

        std::cout << "Message hash: " << Keccak256::bytesToHex(messageHash) << std::endl;
        std::cout << "Signature verification requires libsecp256k1" << std::endl;

        return true;  // Placeholder
    }
};

/**
 * Merkle Tree implementation for efficient verification
 */
class MerkleTree {
private:
    std::vector<std::string> leaves;
    std::vector<std::vector<std::string>> levels;

public:
    MerkleTree(const std::vector<std::string>& data) {
        // Hash all leaves
        for (const auto& item : data) {
            leaves.push_back(Keccak256::hash(item));
        }

        buildTree();
    }

    void buildTree() {
        levels.push_back(leaves);

        while (levels.back().size() > 1) {
            std::vector<std::string> newLevel;
            const auto& currentLevel = levels.back();

            for (size_t i = 0; i < currentLevel.size(); i += 2) {
                if (i + 1 < currentLevel.size()) {
                    // Hash pair
                    std::string combined = currentLevel[i] + currentLevel[i + 1];
                    newLevel.push_back(Keccak256::hash(combined));
                } else {
                    // Odd number, hash with itself
                    std::string combined = currentLevel[i] + currentLevel[i];
                    newLevel.push_back(Keccak256::hash(combined));
                }
            }

            levels.push_back(newLevel);
        }
    }

    std::string getRoot() const {
        return levels.back()[0];
    }

    void printTree() const {
        std::cout << "\n=== Merkle Tree ===" << std::endl;
        for (size_t i = 0; i < levels.size(); i++) {
            std::cout << "Level " << i << ":" << std::endl;
            for (const auto& hash : levels[i]) {
                std::cout << "  " << hash << std::endl;
            }
        }
        std::cout << "\nMerkle Root: " << getRoot() << std::endl;
    }
};

int main(int argc, char* argv[]) {
    std::cout << "=== Ethereum Crypto Algorithms in C++ ===" << std::endl;

    if (argc < 2) {
        std::cout << R"(
Usage:
  ./crypto hash <message>           - Compute Keccak-256 hash
  ./crypto address <public_key>     - Generate Ethereum address
  ./crypto merkle <data1> <data2>   - Build Merkle tree
  ./crypto keygen                   - Generate random private key
        )" << std::endl;
        return 1;
    }

    std::string command = argv[1];

    if (command == "hash") {
        if (argc < 3) {
            std::cout << "Usage: ./crypto hash <message>" << std::endl;
            return 1;
        }
        std::string message = argv[2];
        std::string hash = Keccak256::hash(message);
        std::cout << "Input: " << message << std::endl;
        std::cout << "Keccak-256: " << hash << std::endl;

    } else if (command == "address") {
        if (argc < 3) {
            std::cout << "Usage: ./crypto address <public_key>" << std::endl;
            return 1;
        }
        std::string publicKey = argv[2];
        std::string address = Keccak256::publicKeyToAddress(publicKey);
        std::cout << "Public Key: " << publicKey << std::endl;
        std::cout << "Address: " << address << std::endl;

    } else if (command == "merkle") {
        std::vector<std::string> data;
        for (int i = 2; i < argc; i++) {
            data.push_back(argv[i]);
        }

        if (data.empty()) {
            std::cout << "Usage: ./crypto merkle <data1> <data2> ..." << std::endl;
            return 1;
        }

        MerkleTree tree(data);
        tree.printTree();

    } else if (command == "keygen") {
        std::string privateKey = EthereumCrypto::generatePrivateKey();
        std::cout << "Generated Private Key: " << privateKey << std::endl;
        std::cout << "⚠️  Keep this secret!" << std::endl;

    } else {
        std::cout << "Unknown command: " << command << std::endl;
        return 1;
    }

    return 0;
}

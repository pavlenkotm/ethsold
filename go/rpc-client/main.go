package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

// Web3Client manages Ethereum RPC interactions
type Web3Client struct {
	client *ethclient.Client
	ctx    context.Context
}

// NewWeb3Client creates a new Web3 client
func NewWeb3Client(rpcURL string) (*Web3Client, error) {
	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect: %v", err)
	}

	return &Web3Client{
		client: client,
		ctx:    context.Background(),
	}, nil
}

// GetBalance retrieves the ETH balance of an address
func (w *Web3Client) GetBalance(address string) (*big.Int, error) {
	account := common.HexToAddress(address)
	balance, err := w.client.BalanceAt(w.ctx, account, nil)
	if err != nil {
		return nil, err
	}
	return balance, nil
}

// GetBlockNumber returns the latest block number
func (w *Web3Client) GetBlockNumber() (uint64, error) {
	header, err := w.client.HeaderByNumber(w.ctx, nil)
	if err != nil {
		return 0, err
	}
	return header.Number.Uint64(), nil
}

// GetTransaction retrieves a transaction by hash
func (w *Web3Client) GetTransaction(txHash string) (*types.Transaction, bool, error) {
	hash := common.HexToHash(txHash)
	tx, isPending, err := w.client.TransactionByHash(w.ctx, hash)
	if err != nil {
		return nil, false, err
	}
	return tx, isPending, nil
}

// SendTransaction sends a signed transaction
func (w *Web3Client) SendTransaction(
	privateKeyHex string,
	toAddress string,
	amount *big.Int,
) (string, error) {
	privateKey, err := crypto.HexToECDSA(privateKeyHex)
	if err != nil {
		return "", err
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		return "", fmt.Errorf("error casting public key")
	}

	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	nonce, err := w.client.PendingNonceAt(w.ctx, fromAddress)
	if err != nil {
		return "", err
	}

	gasLimit := uint64(21000)
	gasPrice, err := w.client.SuggestGasPrice(w.ctx)
	if err != nil {
		return "", err
	}

	toAddr := common.HexToAddress(toAddress)
	tx := types.NewTransaction(nonce, toAddr, amount, gasLimit, gasPrice, nil)

	chainID, err := w.client.NetworkID(w.ctx)
	if err != nil {
		return "", err
	}

	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		return "", err
	}

	err = w.client.SendTransaction(w.ctx, signedTx)
	if err != nil {
		return "", err
	}

	return signedTx.Hash().Hex(), nil
}

// SignMessage signs a message with a private key
func SignMessage(privateKeyHex string, message string) (string, error) {
	privateKey, err := crypto.HexToECDSA(privateKeyHex)
	if err != nil {
		return "", err
	}

	data := []byte(message)
	hash := crypto.Keccak256Hash(data)

	signature, err := crypto.Sign(hash.Bytes(), privateKey)
	if err != nil {
		return "", err
	}

	return hexutil.Encode(signature), nil
}

// VerifySignature verifies a message signature
func VerifySignature(message string, signatureHex string, expectedAddress string) (bool, error) {
	data := []byte(message)
	hash := crypto.Keccak256Hash(data)

	signature, err := hexutil.Decode(signatureHex)
	if err != nil {
		return false, err
	}

	// Signature must be 65 bytes (32 + 32 + 1) including recovery ID
	if len(signature) != 65 {
		return false, fmt.Errorf("invalid signature length: expected 65 bytes, got %d", len(signature))
	}

	publicKeyBytes, err := crypto.Ecrecover(hash.Bytes(), signature)
	if err != nil {
		return false, err
	}

	publicKey, err := crypto.UnmarshalPubkey(publicKeyBytes)
	if err != nil {
		return false, err
	}

	recoveredAddress := crypto.PubkeyToAddress(*publicKey)
	expected := common.HexToAddress(expectedAddress)

	return recoveredAddress == expected, nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println(`
Web3 Go Client

Usage:
  go run main.go balance <address>         Get ETH balance
  go run main.go block                     Get latest block number
  go run main.go sign <key> <message>      Sign message
  go run main.go send <key> <to> <amount>  Send ETH (in wei)

Environment:
  ETH_RPC_URL - Ethereum RPC URL (default: http://localhost:8545)
		`)
		return
	}

	rpcURL := os.Getenv("ETH_RPC_URL")
	if rpcURL == "" {
		rpcURL = "http://localhost:8545"
	}

	client, err := NewWeb3Client(rpcURL)
	if err != nil {
		log.Fatal(err)
	}

	command := os.Args[1]

	switch command {
	case "balance":
		if len(os.Args) < 3 {
			log.Fatal("Usage: go run main.go balance <address>")
		}
		balance, err := client.GetBalance(os.Args[2])
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Balance: %s wei\n", balance.String())

	case "block":
		blockNum, err := client.GetBlockNumber()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Latest block: %d\n", blockNum)

	case "sign":
		if len(os.Args) < 4 {
			log.Fatal("Usage: go run main.go sign <private_key> <message>")
		}
		signature, err := SignMessage(os.Args[2], os.Args[3])
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Signature: %s\n", signature)

	case "send":
		if len(os.Args) < 5 {
			log.Fatal("Usage: go run main.go send <key> <to> <amount_wei>")
		}
		amount := new(big.Int)
		ok := amount.SetString(os.Args[4], 10)
		if !ok {
			log.Fatalf("Invalid amount: %s (must be a valid number)", os.Args[4])
		}

		txHash, err := client.SendTransaction(os.Args[2], os.Args[3], amount)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Transaction sent: %s\n", txHash)

	default:
		log.Fatal("Unknown command:", command)
	}
}

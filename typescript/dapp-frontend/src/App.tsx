import { useState, FormEvent } from 'react'
import { useAccount, useBalance, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { formatEther, parseEther } from 'viem'
import { WalletConnect } from './components/WalletConnect'
import { TokenBalance } from './components/TokenBalance'
import './App.css'

// Example ERC20 token ABI
const ERC20_ABI = [
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'recipient', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'transfer',
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'name',
    outputs: [{ name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'symbol',
    outputs: [{ name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const

function App() {
  const { address, isConnected, chain } = useAccount()
  const { data: ethBalance } = useBalance({ address })
  const [tokenAddress, setTokenAddress] = useState<`0x${string}`>('0x')
  const [recipient, setRecipient] = useState<string>('')
  const [amount, setAmount] = useState<string>('')

  // Read token information
  const { data: tokenName } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'name',
  })

  const { data: tokenSymbol } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'symbol',
  })

  const { data: tokenBalance } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
  })

  // Write contract - transfer tokens
  const { data: hash, writeContract, isPending } = useWriteContract()

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    })

  const handleTransfer = async (e: FormEvent) => {
    e.preventDefault()
    if (!recipient || !amount || !tokenAddress) return

    try {
      writeContract({
        address: tokenAddress,
        abi: ERC20_ABI,
        functionName: 'transfer',
        args: [recipient as `0x${string}`, parseEther(amount)],
      })
    } catch (error) {
      console.error('Transfer error:', error)
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🌐 Web3 Multi-Language DApp</h1>
        <p>TypeScript + React + Wagmi + Viem</p>
      </header>

      <main className="main">
        <section className="wallet-section">
          <h2>Wallet Connection</h2>
          <WalletConnect />

          {isConnected && address && (
            <div className="account-info">
              <div className="info-row">
                <strong>Address:</strong>
                <code>{address}</code>
              </div>
              <div className="info-row">
                <strong>Network:</strong>
                <span>{chain?.name || 'Unknown'}</span>
              </div>
              <div className="info-row">
                <strong>ETH Balance:</strong>
                <span>
                  {ethBalance ? formatEther(ethBalance.value) : '0'} ETH
                </span>
              </div>
            </div>
          )}
        </section>

        {isConnected && (
          <>
            <section className="token-section">
              <h2>Token Information</h2>
              <div className="form-group">
                <label htmlFor="token-address">Token Contract Address:</label>
                <input
                  id="token-address"
                  type="text"
                  placeholder="0x..."
                  value={tokenAddress}
                  onChange={(e) => setTokenAddress(e.target.value as `0x${string}`)}
                  className="input"
                />
              </div>

              {tokenName && tokenSymbol && (
                <TokenBalance
                  name={tokenName}
                  symbol={tokenSymbol}
                  balance={tokenBalance ? formatEther(tokenBalance) : '0'}
                />
              )}
            </section>

            <section className="transfer-section">
              <h2>Transfer Tokens</h2>
              <form onSubmit={handleTransfer} className="transfer-form">
                <div className="form-group">
                  <label htmlFor="recipient">Recipient Address:</label>
                  <input
                    id="recipient"
                    type="text"
                    placeholder="0x..."
                    value={recipient}
                    onChange={(e) => setRecipient(e.target.value)}
                    className="input"
                    required
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="amount">Amount:</label>
                  <input
                    id="amount"
                    type="text"
                    placeholder="0.0"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    className="input"
                    required
                  />
                </div>

                <button
                  type="submit"
                  disabled={isPending || isConfirming}
                  className="button primary"
                >
                  {isPending ? 'Confirming...' : isConfirming ? 'Processing...' : 'Transfer'}
                </button>

                {hash && (
                  <div className="tx-status">
                    <p>Transaction Hash: <code>{hash}</code></p>
                    {isConfirming && <p>⏳ Waiting for confirmation...</p>}
                    {isConfirmed && <p>✅ Transaction confirmed!</p>}
                  </div>
                )}
              </form>
            </section>
          </>
        )}
      </main>

      <footer className="footer">
        <p>Built with TypeScript, React, Wagmi, and Viem</p>
        <p>Part of Web3 Multi-Language Repository</p>
      </footer>
    </div>
  )
}

export default App

interface TokenBalanceProps {
  name: string
  symbol: string
  balance: string
}

export function TokenBalance({ name, symbol, balance }: TokenBalanceProps) {
  return (
    <div className="token-info">
      <h3>{name} ({symbol})</h3>
      <div className="balance">
        <span className="balance-label">Your Balance:</span>
        <span className="balance-value">{balance} {symbol}</span>
      </div>
    </div>
  )
}

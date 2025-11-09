import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { TokenBalance } from './TokenBalance'

describe('TokenBalance', () => {
  it('renders token name and symbol', () => {
    render(
      <TokenBalance
        name="Test Token"
        symbol="TEST"
        balance="100.5"
      />
    )

    expect(screen.getByText(/Test Token/i)).toBeInTheDocument()
    expect(screen.getByText(/\(TEST\)/i)).toBeInTheDocument()
  })

  it('displays the correct balance', () => {
    render(
      <TokenBalance
        name="Ethereum"
        symbol="ETH"
        balance="5.25"
      />
    )

    expect(screen.getByText(/5.25 ETH/i)).toBeInTheDocument()
  })

  it('renders with zero balance', () => {
    render(
      <TokenBalance
        name="USDC"
        symbol="USDC"
        balance="0"
      />
    )

    expect(screen.getByText(/0 USDC/i)).toBeInTheDocument()
  })

  it('renders with large balance', () => {
    render(
      <TokenBalance
        name="Bitcoin"
        symbol="BTC"
        balance="1234567.89"
      />
    )

    expect(screen.getByText(/1234567.89 BTC/i)).toBeInTheDocument()
  })

  it('shows balance label', () => {
    render(
      <TokenBalance
        name="Test"
        symbol="TST"
        balance="1"
      />
    )

    expect(screen.getByText(/Your Balance:/i)).toBeInTheDocument()
  })
})

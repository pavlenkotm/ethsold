import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { WalletConnect } from './WalletConnect'

// Mock wagmi hooks
vi.mock('wagmi', () => ({
  useAccount: vi.fn(),
  useConnect: vi.fn(),
  useDisconnect: vi.fn(),
}))

import { useAccount, useConnect, useDisconnect } from 'wagmi'

describe('WalletConnect', () => {
  it('renders connect button when wallet is not connected', () => {
    vi.mocked(useAccount).mockReturnValue({
      address: undefined,
      isConnected: false,
    } as any)

    vi.mocked(useConnect).mockReturnValue({
      connect: vi.fn(),
      connectors: [
        { id: '1', name: 'MetaMask' },
        { id: '2', name: 'WalletConnect' },
      ],
      error: null,
    } as any)

    vi.mocked(useDisconnect).mockReturnValue({
      disconnect: vi.fn(),
    } as any)

    render(<WalletConnect />)

    expect(screen.getByText(/Connect your wallet/i)).toBeInTheDocument()
    expect(screen.getByText(/Connect MetaMask/i)).toBeInTheDocument()
    expect(screen.getByText(/Connect WalletConnect/i)).toBeInTheDocument()
  })

  it('renders disconnect button when wallet is connected', () => {
    const mockAddress = '0x1234567890123456789012345678901234567890'

    vi.mocked(useAccount).mockReturnValue({
      address: mockAddress as `0x${string}`,
      isConnected: true,
    } as any)

    vi.mocked(useConnect).mockReturnValue({
      connect: vi.fn(),
      connectors: [],
      error: null,
    } as any)

    vi.mocked(useDisconnect).mockReturnValue({
      disconnect: vi.fn(),
    } as any)

    render(<WalletConnect />)

    expect(screen.getByText(/✅ Connected:/i)).toBeInTheDocument()
    expect(screen.getByText(/Disconnect/i)).toBeInTheDocument()
  })

  it('displays truncated address when connected', () => {
    const mockAddress = '0x1234567890123456789012345678901234567890'

    vi.mocked(useAccount).mockReturnValue({
      address: mockAddress as `0x${string}`,
      isConnected: true,
    } as any)

    vi.mocked(useConnect).mockReturnValue({
      connect: vi.fn(),
      connectors: [],
      error: null,
    } as any)

    vi.mocked(useDisconnect).mockReturnValue({
      disconnect: vi.fn(),
    } as any)

    render(<WalletConnect />)

    // Should show first 6 and last 4 characters
    expect(screen.getByText(/0x1234\.\.\.7890/i)).toBeInTheDocument()
  })

  it('displays error message when connection fails', () => {
    vi.mocked(useAccount).mockReturnValue({
      address: undefined,
      isConnected: false,
    } as any)

    vi.mocked(useConnect).mockReturnValue({
      connect: vi.fn(),
      connectors: [{ id: '1', name: 'MetaMask' }],
      error: new Error('Connection failed'),
    } as any)

    vi.mocked(useDisconnect).mockReturnValue({
      disconnect: vi.fn(),
    } as any)

    render(<WalletConnect />)

    expect(screen.getByText(/Connection failed/i)).toBeInTheDocument()
  })
})

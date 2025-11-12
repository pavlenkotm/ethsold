# 🌌 Cosmos SDK Module (Go)

Production-ready custom module for Cosmos SDK blockchains written in Go.

## 📋 Overview

Cosmos SDK is a framework for building application-specific blockchains. This module demonstrates a custom counter module that can be integrated into any Cosmos SDK chain.

### Module Included

**Counter Module** - A custom Cosmos SDK module with:
- State management with Keeper
- Custom message types (Increment, Decrement, Reset)
- Event emissions
- Query endpoints
- Transaction handling

---

## 🚀 Prerequisites

### Install Go

```bash
# Install Go 1.21+
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# Add to PATH
export PATH=$PATH:/usr/local/go/bin

# Verify installation
go version
```

### Install Ignite CLI (Optional but recommended)

```bash
# Install Ignite for scaffolding Cosmos chains
curl https://get.ignite.com/cli! | bash

# Verify installation
ignite version
```

---

## 📦 Project Structure

```
go/cosmos-module/
├── keeper/
│   └── keeper.go         # State management and business logic
├── types/
│   ├── msgs.go          # Message type definitions
│   └── codec.go         # Encoding/decoding
├── go.mod               # Go dependencies
└── README.md            # This file
```

---

## 🛠️ Setup

### Initialize Go Module

```bash
cd go/cosmos-module

# Download dependencies
go mod download
go mod tidy
```

---

## 🔨 Integration into Cosmos Chain

### 1. Add Module to App

```go
// app/app.go
import (
    counterkeeper "github.com/example/counter/keeper"
    countertypes "github.com/example/counter/types"
)

type App struct {
    // ... other keepers
    CounterKeeper counterkeeper.Keeper
}

func NewApp(...) *App {
    // ... initialization

    app.CounterKeeper = counterkeeper.NewKeeper(
        appCodec,
        keys[countertypes.StoreKey],
        keys[countertypes.MemStoreKey],
    )

    // ... rest of setup
}
```

### 2. Register Module Routes

```go
// app/app.go
app.ModuleManager = module.NewManager(
    // ... other modules
    counter.NewAppModule(appCodec, app.CounterKeeper),
)
```

### 3. Add to Genesis

```go
// app/genesis.go
func (app *App) InitChainer(ctx sdk.Context, req abci.RequestInitChain) abci.ResponseInitChain {
    // Initialize counter state
    app.CounterKeeper.SetCounter(ctx, 0)
    // ...
}
```

---

## 🧪 Testing

### Unit Tests

Create `keeper/keeper_test.go`:

```go
package keeper_test

import (
    "testing"

    "github.com/stretchr/testify/require"
    sdk "github.com/cosmos/cosmos-sdk/types"
)

func TestIncrement(t *testing.T) {
    keeper, ctx := setupKeeper(t)

    // Test increment
    result := keeper.IncrementCounter(ctx)
    require.Equal(t, int64(1), result)

    // Test get
    counter := keeper.GetCounter(ctx)
    require.Equal(t, int64(1), counter)
}

func TestDecrement(t *testing.T) {
    keeper, ctx := setupKeeper(t)

    keeper.SetCounter(ctx, 5)
    result := keeper.DecrementCounter(ctx)
    require.Equal(t, int64(4), result)
}
```

### Run Tests

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific test
go test -v -run TestIncrement ./keeper
```

---

## 🚀 Usage Examples

### Using with `ignite chain`

```bash
# Scaffold new chain with Ignite
ignite scaffold chain example

# Add counter module
cd example

# Scaffold module
ignite scaffold module counter

# Scaffold message types
ignite scaffold message increment --module counter
ignite scaffold message decrement --module counter
ignite scaffold message reset --module counter

# Scaffold query
ignite scaffold query get-counter --module counter

# Start chain
ignite chain serve
```

### Transactions

```bash
# Increment counter
exampled tx counter increment \
  --from alice \
  --chain-id example \
  --yes

# Decrement counter
exampled tx counter decrement \
  --from alice \
  --chain-id example \
  --yes

# Reset counter
exampled tx counter reset \
  --from alice \
  --chain-id example \
  --yes
```

### Queries

```bash
# Get counter value
exampled query counter get-counter

# Get user increment count
exampled query counter user-increments cosmos1...
```

---

## 📚 Module Features

### Keeper Functions

The Keeper handles all state management:

```go
// State operations
GetCounter(ctx) int64
SetCounter(ctx, counter int64)
IncrementCounter(ctx) int64
DecrementCounter(ctx) int64
ResetCounter(ctx)

// User tracking
GetUserIncrementCount(ctx, address) int64
IncrementUserCount(ctx, address)
```

### Message Types

Three message types for state changes:

1. **MsgIncrement** - Increment counter by 1
2. **MsgDecrement** - Decrement counter by 1
3. **MsgReset** - Reset counter to 0

### Events

Events emitted on state changes:

```go
sdk.NewEvent(
    "counter_incremented",
    sdk.NewAttribute("value", "1"),
)

sdk.NewEvent(
    "counter_decremented",
    sdk.NewAttribute("value", "0"),
)

sdk.NewEvent(
    "counter_reset",
    sdk.NewAttribute("value", "0"),
)
```

---

## 🔒 Security Features

- ✅ Address validation
- ✅ Type-safe message handling
- ✅ Keeper pattern for state encapsulation
- ✅ Event logging for transparency
- ✅ Deterministic execution
- ✅ Consensus-based state changes

---

## 🌐 Compatible Chains

This module can be integrated into any Cosmos SDK chain:

- **Cosmos Hub** - The main Cosmos blockchain
- **Osmosis** - DEX and AMM protocol
- **Juno** - Smart contract platform
- **Evmos** - EVM on Cosmos
- **Injective** - DeFi protocol
- **Secret Network** - Privacy-preserving contracts
- Custom chains built with Cosmos SDK

---

## 🔧 Advanced Features

### Adding Params

```go
// types/params.go
type Params struct {
    MaxValue int64 `json:"max_value"`
}

// keeper/params.go
func (k Keeper) GetParams(ctx sdk.Context) Params {
    store := ctx.KVStore(k.storeKey)
    bz := store.Get(ParamsKey)
    var params Params
    k.cdc.MustUnmarshal(bz, &params)
    return params
}
```

### Adding Queries

```go
// types/query.go
type QueryCounterRequest struct{}

type QueryCounterResponse struct {
    Value int64 `json:"value"`
}

// keeper/grpc_query.go
func (k Keeper) Counter(
    goCtx context.Context,
    req *types.QueryCounterRequest,
) (*types.QueryCounterResponse, error) {
    ctx := sdk.UnwrapSDKContext(goCtx)
    counter := k.GetCounter(ctx)
    return &types.QueryCounterResponse{Value: counter}, nil
}
```

### Adding CLI

```go
// client/cli/tx.go
func GetTxCmd() *cobra.Command {
    cmd := &cobra.Command{
        Use:   "counter",
        Short: "Counter transaction subcommands",
    }

    cmd.AddCommand(
        CmdIncrement(),
        CmdDecrement(),
        CmdReset(),
    )

    return cmd
}
```

---

## 📖 Resources

- [Cosmos SDK Documentation](https://docs.cosmos.network/)
- [Cosmos SDK Tutorials](https://tutorials.cosmos.network/)
- [Ignite CLI](https://docs.ignite.com/)
- [Cosmos Developer Portal](https://developers.cosmos.network/)
- [Cosmos GitHub](https://github.com/cosmos/cosmos-sdk)
- [Tendermint Core](https://docs.tendermint.com/)

---

## 🧪 Integration Testing

```go
package integration_test

import (
    "testing"

    "github.com/cosmos/cosmos-sdk/simapp"
    sdk "github.com/cosmos/cosmos-sdk/types"
    "github.com/stretchr/testify/suite"
)

type IntegrationTestSuite struct {
    suite.Suite
    app    *simapp.SimApp
    ctx    sdk.Context
}

func (suite *IntegrationTestSuite) TestCounterLifecycle() {
    // Test full lifecycle
    keeper := suite.app.CounterKeeper

    // Increment
    keeper.IncrementCounter(suite.ctx)
    suite.Equal(int64(1), keeper.GetCounter(suite.ctx))

    // Decrement
    keeper.DecrementCounter(suite.ctx)
    suite.Equal(int64(0), keeper.GetCounter(suite.ctx))

    // Reset
    keeper.SetCounter(suite.ctx, 100)
    keeper.ResetCounter(suite.ctx)
    suite.Equal(int64(0), keeper.GetCounter(suite.ctx))
}

func TestIntegrationTestSuite(t *testing.T) {
    suite.Run(t, new(IntegrationTestSuite))
}
```

---

## 📊 Performance Considerations

### State Management
- Use efficient key design
- Minimize storage operations
- Batch operations when possible
- Use iterators carefully

### Gas Optimization
- Keep operations simple
- Avoid expensive loops
- Cache frequently accessed data
- Use appropriate data structures

---

## 🔄 Upgrade Path

```go
// Implement upgrade handler
app.UpgradeKeeper.SetUpgradeHandler(
    "v2",
    func(ctx sdk.Context, plan upgradetypes.Plan, vm module.VersionMap) (module.VersionMap, error) {
        // Migrate counter module
        return app.ModuleManager.RunMigrations(ctx, app.configurator, vm)
    },
)
```

---

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code follows Go best practices
- All tests pass
- Add tests for new features
- Update documentation

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Related

- [Go RPC Client](../rpc-client/)
- [Rust Solana Program](../../rust/solana-program/)
- [NEAR Contract](../../rust/near-contract/)

---

**Building on Cosmos with Go 🌌**

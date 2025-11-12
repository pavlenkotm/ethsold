package keeper

import (
	"fmt"

	"github.com/cosmos/cosmos-sdk/codec"
	storetypes "github.com/cosmos/cosmos-sdk/store/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/tendermint/tendermint/libs/log"
)

// Keeper maintains the link to storage and exposes getter/setter methods
type Keeper struct {
	cdc      codec.BinaryCodec
	storeKey storetypes.StoreKey
	memKey   storetypes.StoreKey
}

// NewKeeper creates a new counter Keeper instance
func NewKeeper(
	cdc codec.BinaryCodec,
	storeKey,
	memKey storetypes.StoreKey,
) *Keeper {
	return &Keeper{
		cdc:      cdc,
		storeKey: storeKey,
		memKey:   memKey,
	}
}

// Logger returns a module-specific logger
func (k Keeper) Logger(ctx sdk.Context) log.Logger {
	return ctx.Logger().With("module", fmt.Sprintf("x/%s", "counter"))
}

// GetCounter retrieves the counter value from store
func (k Keeper) GetCounter(ctx sdk.Context) int64 {
	store := ctx.KVStore(k.storeKey)
	bz := store.Get([]byte("counter"))
	if bz == nil {
		return 0
	}

	var counter int64
	k.cdc.MustUnmarshal(bz, &counter)
	return counter
}

// SetCounter stores the counter value
func (k Keeper) SetCounter(ctx sdk.Context, counter int64) {
	store := ctx.KVStore(k.storeKey)
	bz := k.cdc.MustMarshal(&counter)
	store.Set([]byte("counter"), bz)
}

// IncrementCounter increments the counter by 1
func (k Keeper) IncrementCounter(ctx sdk.Context) int64 {
	counter := k.GetCounter(ctx)
	counter++
	k.SetCounter(ctx, counter)

	// Emit event
	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			"counter_incremented",
			sdk.NewAttribute("value", fmt.Sprintf("%d", counter)),
		),
	)

	return counter
}

// DecrementCounter decrements the counter by 1
func (k Keeper) DecrementCounter(ctx sdk.Context) int64 {
	counter := k.GetCounter(ctx)
	if counter > 0 {
		counter--
		k.SetCounter(ctx, counter)

		// Emit event
		ctx.EventManager().EmitEvent(
			sdk.NewEvent(
				"counter_decremented",
				sdk.NewAttribute("value", fmt.Sprintf("%d", counter)),
			),
		)
	}

	return counter
}

// ResetCounter resets the counter to zero
func (k Keeper) ResetCounter(ctx sdk.Context) {
	k.SetCounter(ctx, 0)

	// Emit event
	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			"counter_reset",
			sdk.NewAttribute("value", "0"),
		),
	)
}

// GetUserIncrementCount retrieves the increment count for a specific user
func (k Keeper) GetUserIncrementCount(ctx sdk.Context, address string) int64 {
	store := ctx.KVStore(k.storeKey)
	key := []byte(fmt.Sprintf("user_%s", address))
	bz := store.Get(key)
	if bz == nil {
		return 0
	}

	var count int64
	k.cdc.MustUnmarshal(bz, &count)
	return count
}

// IncrementUserCount increments the user's increment count
func (k Keeper) IncrementUserCount(ctx sdk.Context, address string) {
	count := k.GetUserIncrementCount(ctx, address)
	count++

	store := ctx.KVStore(k.storeKey)
	key := []byte(fmt.Sprintf("user_%s", address))
	bz := k.cdc.MustMarshal(&count)
	store.Set(key, bz)
}

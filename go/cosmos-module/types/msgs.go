package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

// Message types for the counter module
const (
	TypeMsgIncrement = "increment"
	TypeMsgDecrement = "decrement"
	TypeMsgReset     = "reset"
)

var (
	_ sdk.Msg = &MsgIncrement{}
	_ sdk.Msg = &MsgDecrement{}
	_ sdk.Msg = &MsgReset{}
)

// MsgIncrement defines the Increment message
type MsgIncrement struct {
	Creator string `json:"creator"`
}

// NewMsgIncrement creates a new MsgIncrement instance
func NewMsgIncrement(creator string) *MsgIncrement {
	return &MsgIncrement{
		Creator: creator,
	}
}

// Route implements the sdk.Msg interface
func (msg *MsgIncrement) Route() string {
	return "counter"
}

// Type implements the sdk.Msg interface
func (msg *MsgIncrement) Type() string {
	return TypeMsgIncrement
}

// GetSigners implements the sdk.Msg interface
func (msg *MsgIncrement) GetSigners() []sdk.AccAddress {
	creator, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{creator}
}

// GetSignBytes implements the sdk.Msg interface
func (msg *MsgIncrement) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

// ValidateBasic implements the sdk.Msg interface
func (msg *MsgIncrement) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
	}
	return nil
}

// MsgDecrement defines the Decrement message
type MsgDecrement struct {
	Creator string `json:"creator"`
}

// NewMsgDecrement creates a new MsgDecrement instance
func NewMsgDecrement(creator string) *MsgDecrement {
	return &MsgDecrement{
		Creator: creator,
	}
}

// Route implements the sdk.Msg interface
func (msg *MsgDecrement) Route() string {
	return "counter"
}

// Type implements the sdk.Msg interface
func (msg *MsgDecrement) Type() string {
	return TypeMsgDecrement
}

// GetSigners implements the sdk.Msg interface
func (msg *MsgDecrement) GetSigners() []sdk.AccAddress {
	creator, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{creator}
}

// GetSignBytes implements the sdk.Msg interface
func (msg *MsgDecrement) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

// ValidateBasic implements the sdk.Msg interface
func (msg *MsgDecrement) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
	}
	return nil
}

// MsgReset defines the Reset message
type MsgReset struct {
	Creator string `json:"creator"`
}

// NewMsgReset creates a new MsgReset instance
func NewMsgReset(creator string) *MsgReset {
	return &MsgReset{
		Creator: creator,
	}
}

// Route implements the sdk.Msg interface
func (msg *MsgReset) Route() string {
	return "counter"
}

// Type implements the sdk.Msg interface
func (msg *MsgReset) Type() string {
	return TypeMsgReset
}

// GetSigners implements the sdk.Msg interface
func (msg *MsgReset) GetSigners() []sdk.AccAddress {
	creator, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{creator}
}

// GetSignBytes implements the sdk.Msg interface
func (msg *MsgReset) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

// ValidateBasic implements the sdk.Msg interface
func (msg *MsgReset) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
	}
	return nil
}

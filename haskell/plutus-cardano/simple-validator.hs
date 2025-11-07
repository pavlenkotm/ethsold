{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeApplications           #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}

module SimpleValidator where

import           PlutusTx.Prelude       hiding (Semigroup(..), unless)
import           Plutus.V2.Ledger.Api
import           Plutus.V2.Ledger.Contexts
import qualified PlutusTx
import           PlutusTx.Builtins
import           Ledger                 hiding (singleton)
import           Ledger.Ada             as Ada

-- | Simple Vesting Validator
-- Locks funds until a specific time, then allows withdrawal by beneficiary

-- | Datum: Contains beneficiary and deadline information
data VestingDatum = VestingDatum
    { beneficiary :: PaymentPubKeyHash
    , deadline    :: POSIXTime
    } deriving Show

PlutusTx.unstableMakeIsData ''VestingDatum

-- | Redeemer: Action to perform
data VestingRedeemer = Claim
    deriving Show

PlutusTx.unstableMakeIsData ''VestingRedeemer

-- | Validator logic
{-# INLINABLE mkValidator #-}
mkValidator :: VestingDatum -> VestingRedeemer -> ScriptContext -> Bool
mkValidator dat Claim ctx =
    traceIfFalse "beneficiary's signature missing" signedByBeneficiary &&
    traceIfFalse "deadline not reached" deadlinereached
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    signedByBeneficiary :: Bool
    signedByBeneficiary = txSignedBy info $ unPaymentPubKeyHash $ beneficiary dat

    deadlineReached :: Bool
    deadlineReached = contains (from $ deadline dat) $ txInfoValidRange info

-- | Compile the validator
validator :: Validator
validator = mkValidatorScript $$(PlutusTx.compile [|| mkValidator ||])

-- | Validator hash
valHash :: Ledger.ValidatorHash
valHash = Scripts.validatorHash validator

-- | Script address
scrAddress :: Ledger.Address
scrAddress = scriptHashAddress valHash

-- | Simple Token Contract
-- Demonstrates a basic token minting policy

-- | Token name
tokenName :: TokenName
tokenName = TokenName "MYTOKEN"

{-# INLINABLE mkPolicy #-}
mkPolicy :: PaymentPubKeyHash -> () -> ScriptContext -> Bool
mkPolicy pkh () ctx = txSignedBy (scriptContextTxInfo ctx) $ unPaymentPubKeyHash pkh

policy :: PaymentPubKeyHash -> Scripts.MintingPolicy
policy pkh = mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \pkh' -> Scripts.mkUntypedMintingPolicy $ mkPolicy pkh' ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode pkh

-- | Currency symbol
curSymbol :: PaymentPubKeyHash -> CurrencySymbol
curSymbol = scriptCurrencySymbol . policy

-- | Example Off-Chain Code
-- Functions that would be used in a DApp

-- | Create vesting transaction
vestFunds :: PaymentPubKeyHash -> POSIXTime -> Integer -> Tx
vestFunds beneficiary deadline amount =
    let dat = VestingDatum
            { beneficiary = beneficiary
            , deadline    = deadline
            }
        tx = Constraints.mustPayToTheScript dat (Ada.lovelaceValueOf amount)
    in tx

-- | Claim vested funds
claimFunds :: VestingDatum -> Tx
claimFunds dat =
    let redeemer = Claim
        tx = Constraints.mustSpendScriptOutput
                (TxOutRef "..." 0)  -- Reference to UTXO
                (Redeemer $ PlutusTx.toBuiltinData redeemer)
    in tx

-- | Utility functions
{-# INLINABLE lovelaces #-}
lovelaces :: Value -> Integer
lovelaces = Ada.getLovelace . Ada.fromValue

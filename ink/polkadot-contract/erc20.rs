#![cfg_attr(not(feature = "std"), no_std, no_main)]

/// Ink! ERC-20 Token Implementation for Polkadot/Substrate
/// Standard fungible token with PSP22 interface

#[ink::contract]
mod erc20 {
    use ink::storage::Mapping;

    /// ERC-20 Token Storage
    #[ink(storage)]
    pub struct Erc20 {
        /// Total token supply
        total_supply: Balance,
        /// Token balances
        balances: Mapping<AccountId, Balance>,
        /// Token allowances
        allowances: Mapping<(AccountId, AccountId), Balance>,
        /// Token name
        name: String,
        /// Token symbol
        symbol: String,
        /// Token decimals
        decimals: u8,
        /// Contract owner
        owner: AccountId,
    }

    /// Events
    #[ink(event)]
    pub struct Transfer {
        #[ink(topic)]
        from: Option<AccountId>,
        #[ink(topic)]
        to: Option<AccountId>,
        value: Balance,
    }

    #[ink(event)]
    pub struct Approval {
        #[ink(topic)]
        owner: AccountId,
        #[ink(topic)]
        spender: AccountId,
        value: Balance,
    }

    /// Errors
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        InsufficientBalance,
        InsufficientAllowance,
        Unauthorized,
        ZeroAddress,
    }

    pub type Result<T> = core::result::Result<T, Error>;

    impl Erc20 {
        /// Constructor
        #[ink(constructor)]
        pub fn new(
            name: String,
            symbol: String,
            decimals: u8,
            initial_supply: Balance,
        ) -> Self {
            let caller = Self::env().caller();
            let mut balances = Mapping::default();
            balances.insert(caller, &initial_supply);

            Self::env().emit_event(Transfer {
                from: None,
                to: Some(caller),
                value: initial_supply,
            });

            Self {
                total_supply: initial_supply,
                balances,
                allowances: Mapping::default(),
                name,
                symbol,
                decimals,
                owner: caller,
            }
        }

        /// Returns token name
        #[ink(message)]
        pub fn name(&self) -> String {
            self.name.clone()
        }

        /// Returns token symbol
        #[ink(message)]
        pub fn symbol(&self) -> String {
            self.symbol.clone()
        }

        /// Returns token decimals
        #[ink(message)]
        pub fn decimals(&self) -> u8 {
            self.decimals
        }

        /// Returns total token supply
        #[ink(message)]
        pub fn total_supply(&self) -> Balance {
            self.total_supply
        }

        /// Returns balance of an account
        #[ink(message)]
        pub fn balance_of(&self, owner: AccountId) -> Balance {
            self.balances.get(owner).unwrap_or(0)
        }

        /// Returns allowance from owner to spender
        #[ink(message)]
        pub fn allowance(&self, owner: AccountId, spender: AccountId) -> Balance {
            self.allowances.get((owner, spender)).unwrap_or(0)
        }

        /// Transfer tokens
        #[ink(message)]
        pub fn transfer(&mut self, to: AccountId, value: Balance) -> Result<()> {
            let from = self.env().caller();
            self.transfer_from_to(&from, &to, value)
        }

        /// Approve spender to spend tokens
        #[ink(message)]
        pub fn approve(&mut self, spender: AccountId, value: Balance) -> Result<()> {
            let owner = self.env().caller();
            self.allowances.insert((owner, spender), &value);

            self.env().emit_event(Approval {
                owner,
                spender,
                value,
            });

            Ok(())
        }

        /// Transfer tokens on behalf of another account
        #[ink(message)]
        pub fn transfer_from(
            &mut self,
            from: AccountId,
            to: AccountId,
            value: Balance,
        ) -> Result<()> {
            let caller = self.env().caller();
            let allowance = self.allowance(from, caller);

            if allowance < value {
                return Err(Error::InsufficientAllowance);
            }

            self.allowances.insert((from, caller), &(allowance - value));
            self.transfer_from_to(&from, &to, value)
        }

        /// Mint new tokens (owner only)
        #[ink(message)]
        pub fn mint(&mut self, to: AccountId, value: Balance) -> Result<()> {
            let caller = self.env().caller();
            if caller != self.owner {
                return Err(Error::Unauthorized);
            }

            let balance = self.balance_of(to);
            self.balances.insert(to, &(balance + value));
            self.total_supply += value;

            self.env().emit_event(Transfer {
                from: None,
                to: Some(to),
                value,
            });

            Ok(())
        }

        /// Burn tokens
        #[ink(message)]
        pub fn burn(&mut self, value: Balance) -> Result<()> {
            let caller = self.env().caller();
            let balance = self.balance_of(caller);

            if balance < value {
                return Err(Error::InsufficientBalance);
            }

            self.balances.insert(caller, &(balance - value));
            self.total_supply -= value;

            self.env().emit_event(Transfer {
                from: Some(caller),
                to: None,
                value,
            });

            Ok(())
        }

        /// Internal transfer helper
        fn transfer_from_to(
            &mut self,
            from: &AccountId,
            to: &AccountId,
            value: Balance,
        ) -> Result<()> {
            let from_balance = self.balance_of(*from);
            if from_balance < value {
                return Err(Error::InsufficientBalance);
            }

            self.balances.insert(*from, &(from_balance - value));
            let to_balance = self.balance_of(*to);
            self.balances.insert(*to, &(to_balance + value));

            self.env().emit_event(Transfer {
                from: Some(*from),
                to: Some(*to),
                value,
            });

            Ok(())
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;

        #[ink::test]
        fn new_works() {
            let erc20 = Erc20::new(
                "TestToken".to_string(),
                "TST".to_string(),
                18,
                1000,
            );
            assert_eq!(erc20.total_supply(), 1000);
            assert_eq!(erc20.name(), "TestToken");
            assert_eq!(erc20.symbol(), "TST");
            assert_eq!(erc20.decimals(), 18);
        }

        #[ink::test]
        fn transfer_works() {
            let mut erc20 = Erc20::new(
                "TestToken".to_string(),
                "TST".to_string(),
                18,
                1000,
            );
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            assert!(erc20.transfer(accounts.bob, 100).is_ok());
            assert_eq!(erc20.balance_of(accounts.alice), 900);
            assert_eq!(erc20.balance_of(accounts.bob), 100);
        }

        #[ink::test]
        fn approve_works() {
            let mut erc20 = Erc20::new(
                "TestToken".to_string(),
                "TST".to_string(),
                18,
                1000,
            );
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            assert!(erc20.approve(accounts.bob, 100).is_ok());
            assert_eq!(erc20.allowance(accounts.alice, accounts.bob), 100);
        }
    }
}

#![cfg_attr(not(feature = "std"), no_std, no_main)]

/// Ink! Smart Contract for Polkadot/Substrate
/// A simple counter contract with ownership and events

#[ink::contract]
mod counter {
    use ink::storage::Mapping;

    /// Storage structure for the counter contract
    #[ink(storage)]
    pub struct Counter {
        /// Current counter value
        value: i32,
        /// Contract owner
        owner: AccountId,
        /// Track increment counts per user
        user_increments: Mapping<AccountId, u32>,
    }

    /// Event emitted when counter is incremented
    #[ink(event)]
    pub struct Incremented {
        #[ink(topic)]
        by: AccountId,
        value: i32,
    }

    /// Event emitted when counter is decremented
    #[ink(event)]
    pub struct Decremented {
        #[ink(topic)]
        by: AccountId,
        value: i32,
    }

    /// Event emitted when counter is reset
    #[ink(event)]
    pub struct Reset {
        #[ink(topic)]
        by: AccountId,
    }

    /// Errors that can occur in the contract
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        /// Caller is not authorized
        Unauthorized,
        /// Counter overflow
        Overflow,
        /// Counter underflow
        Underflow,
    }

    /// Type alias for Result with our Error type
    pub type Result<T> = core::result::Result<T, Error>;

    impl Counter {
        /// Constructor initializes the counter with a starting value
        #[ink(constructor)]
        pub fn new(init_value: i32) -> Self {
            let caller = Self::env().caller();
            Self {
                value: init_value,
                owner: caller,
                user_increments: Mapping::default(),
            }
        }

        /// Constructor that initializes counter to zero
        #[ink(constructor)]
        pub fn default() -> Self {
            Self::new(0)
        }

        /// Increment the counter by 1
        #[ink(message)]
        pub fn increment(&mut self) -> Result<()> {
            self.value = self.value.checked_add(1).ok_or(Error::Overflow)?;

            let caller = self.env().caller();
            let count = self.user_increments.get(caller).unwrap_or(0);
            self.user_increments.insert(caller, &(count + 1));

            self.env().emit_event(Incremented {
                by: caller,
                value: self.value,
            });

            Ok(())
        }

        /// Decrement the counter by 1
        #[ink(message)]
        pub fn decrement(&mut self) -> Result<()> {
            self.value = self.value.checked_sub(1).ok_or(Error::Underflow)?;

            let caller = self.env().caller();
            self.env().emit_event(Decremented {
                by: caller,
                value: self.value,
            });

            Ok(())
        }

        /// Get the current counter value
        #[ink(message)]
        pub fn get(&self) -> i32 {
            self.value
        }

        /// Reset counter to zero (owner only)
        #[ink(message)]
        pub fn reset(&mut self) -> Result<()> {
            let caller = self.env().caller();
            if caller != self.owner {
                return Err(Error::Unauthorized);
            }

            self.value = 0;
            self.env().emit_event(Reset { by: caller });

            Ok(())
        }

        /// Get the contract owner
        #[ink(message)]
        pub fn get_owner(&self) -> AccountId {
            self.owner
        }

        /// Get how many times a user has incremented
        #[ink(message)]
        pub fn get_user_increments(&self, user: AccountId) -> u32 {
            self.user_increments.get(user).unwrap_or(0)
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;

        #[ink::test]
        fn default_works() {
            let counter = Counter::default();
            assert_eq!(counter.get(), 0);
        }

        #[ink::test]
        fn new_works() {
            let counter = Counter::new(42);
            assert_eq!(counter.get(), 42);
        }

        #[ink::test]
        fn increment_works() {
            let mut counter = Counter::new(10);
            assert!(counter.increment().is_ok());
            assert_eq!(counter.get(), 11);
        }

        #[ink::test]
        fn decrement_works() {
            let mut counter = Counter::new(10);
            assert!(counter.decrement().is_ok());
            assert_eq!(counter.get(), 9);
        }

        #[ink::test]
        fn reset_works() {
            let mut counter = Counter::new(42);
            assert!(counter.reset().is_ok());
            assert_eq!(counter.get(), 0);
        }

        #[ink::test]
        fn underflow_fails() {
            let mut counter = Counter::new(i32::MIN);
            assert_eq!(counter.decrement(), Err(Error::Underflow));
        }

        #[ink::test]
        fn overflow_fails() {
            let mut counter = Counter::new(i32::MAX);
            assert_eq!(counter.increment(), Err(Error::Overflow));
        }
    }
}

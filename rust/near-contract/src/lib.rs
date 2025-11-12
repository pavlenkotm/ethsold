use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::collections::{LookupMap, Vector};
use near_sdk::{env, near_bindgen, AccountId, PanicOnDefault};

/// NEAR Protocol Smart Contract
/// A counter contract with owner management and event logging

#[near_bindgen]
#[derive(BorshDeserialize, BorshSerialize, PanicOnDefault)]
pub struct Counter {
    /// Current counter value
    value: i64,
    /// Contract owner
    owner: AccountId,
    /// Total number of increments
    total_increments: u64,
    /// Track per-user increments
    user_increments: LookupMap<AccountId, u64>,
    /// Event log
    event_log: Vector<String>,
}

#[near_bindgen]
impl Counter {
    /// Initialize the contract
    #[init]
    pub fn new(initial_value: i64) -> Self {
        assert!(!env::state_exists(), "Already initialized");
        Self {
            value: initial_value,
            owner: env::predecessor_account_id(),
            total_increments: 0,
            user_increments: LookupMap::new(b"u"),
            event_log: Vector::new(b"e"),
        }
    }

    /// Get current counter value
    pub fn get_counter(&self) -> i64 {
        self.value
    }

    /// Get contract owner
    pub fn get_owner(&self) -> AccountId {
        self.owner.clone()
    }

    /// Get total increments
    pub fn get_total_increments(&self) -> u64 {
        self.total_increments
    }

    /// Get user-specific increments
    pub fn get_user_increments(&self, account_id: AccountId) -> u64 {
        self.user_increments.get(&account_id).unwrap_or(0)
    }

    /// Increment counter by 1
    pub fn increment(&mut self) {
        self.value = self.value.checked_add(1).expect("Overflow error");
        self.total_increments += 1;

        let caller = env::predecessor_account_id();
        let user_count = self.user_increments.get(&caller).unwrap_or(0);
        self.user_increments.insert(&caller, &(user_count + 1));

        // Log event
        let event = format!(
            "{{\"event\":\"increment\",\"by\":\"{}\",\"value\":{}}}",
            caller, self.value
        );
        env::log_str(&event);
        self.event_log.push(&event);
    }

    /// Decrement counter by 1
    pub fn decrement(&mut self) {
        self.value = self.value.checked_sub(1).expect("Underflow error");

        let caller = env::predecessor_account_id();
        let event = format!(
            "{{\"event\":\"decrement\",\"by\":\"{}\",\"value\":{}}}",
            caller, self.value
        );
        env::log_str(&event);
        self.event_log.push(&event);
    }

    /// Increment by custom amount
    pub fn increment_by(&mut self, amount: i64) {
        self.value = self.value.checked_add(amount).expect("Overflow error");

        let caller = env::predecessor_account_id();
        let event = format!(
            "{{\"event\":\"increment_by\",\"by\":\"{}\",\"amount\":{},\"value\":{}}}",
            caller, amount, self.value
        );
        env::log_str(&event);
        self.event_log.push(&event);
    }

    /// Reset counter to zero (owner only)
    pub fn reset(&mut self) {
        self.assert_owner();
        self.value = 0;

        let caller = env::predecessor_account_id();
        let event = format!("{{\"event\":\"reset\",\"by\":\"{}\"}}", caller);
        env::log_str(&event);
        self.event_log.push(&event);
    }

    /// Set counter to specific value (owner only)
    pub fn set_counter(&mut self, value: i64) {
        self.assert_owner();
        self.value = value;

        let caller = env::predecessor_account_id();
        let event = format!(
            "{{\"event\":\"set_counter\",\"by\":\"{}\",\"value\":{}}}",
            caller, value
        );
        env::log_str(&event);
        self.event_log.push(&event);
    }

    /// Get recent events (last 10)
    pub fn get_recent_events(&self) -> Vec<String> {
        let len = self.event_log.len();
        let start = if len > 10 { len - 10 } else { 0 };
        (start..len)
            .map(|i| self.event_log.get(i).unwrap())
            .collect()
    }

    /// Get all events
    pub fn get_all_events(&self) -> Vec<String> {
        (0..self.event_log.len())
            .map(|i| self.event_log.get(i).unwrap())
            .collect()
    }

    /// Clear event log (owner only)
    pub fn clear_events(&mut self) {
        self.assert_owner();
        self.event_log.clear();
    }

    // Private helper functions

    fn assert_owner(&self) {
        assert_eq!(
            env::predecessor_account_id(),
            self.owner,
            "Only owner can call this method"
        );
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use near_sdk::test_utils::{accounts, VMContextBuilder};
    use near_sdk::testing_env;

    fn get_context(predecessor: AccountId) -> VMContextBuilder {
        let mut builder = VMContextBuilder::new();
        builder.predecessor_account_id(predecessor);
        builder
    }

    #[test]
    fn test_new() {
        let context = get_context(accounts(0));
        testing_env!(context.build());

        let contract = Counter::new(0);
        assert_eq!(contract.get_counter(), 0);
    }

    #[test]
    fn test_increment() {
        let context = get_context(accounts(0));
        testing_env!(context.build());

        let mut contract = Counter::new(5);
        contract.increment();
        assert_eq!(contract.get_counter(), 6);
        assert_eq!(contract.get_total_increments(), 1);
    }

    #[test]
    fn test_decrement() {
        let context = get_context(accounts(0));
        testing_env!(context.build());

        let mut contract = Counter::new(5);
        contract.decrement();
        assert_eq!(contract.get_counter(), 4);
    }

    #[test]
    fn test_increment_by() {
        let context = get_context(accounts(0));
        testing_env!(context.build());

        let mut contract = Counter::new(10);
        contract.increment_by(5);
        assert_eq!(contract.get_counter(), 15);
    }

    #[test]
    fn test_reset() {
        let context = get_context(accounts(0));
        testing_env!(context.build());

        let mut contract = Counter::new(42);
        contract.reset();
        assert_eq!(contract.get_counter(), 0);
    }

    #[test]
    #[should_panic(expected = "Only owner can call this method")]
    fn test_reset_not_owner() {
        let mut context = get_context(accounts(0));
        testing_env!(context.build());

        let mut contract = Counter::new(42);

        // Change caller
        context.predecessor_account_id(accounts(1));
        testing_env!(context.build());

        contract.reset();
    }
}

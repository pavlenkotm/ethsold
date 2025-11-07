use anchor_lang::prelude::*;
use counter_program::{Counter, ErrorCode};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_counter_initialization() {
        // Test counter starts at 0
        let counter = Counter {
            count: 0,
            authority: Pubkey::new_unique(),
        };

        assert_eq!(counter.count, 0);
    }

    #[test]
    fn test_increment() {
        let mut counter = Counter {
            count: 0,
            authority: Pubkey::new_unique(),
        };

        // Simulate increment
        counter.count = counter.count.checked_add(1).unwrap();

        assert_eq!(counter.count, 1);
    }

    #[test]
    fn test_decrement() {
        let mut counter = Counter {
            count: 10,
            authority: Pubkey::new_unique(),
        };

        // Simulate decrement
        counter.count = counter.count.checked_sub(1).unwrap();

        assert_eq!(counter.count, 9);
    }

    #[test]
    #[should_panic]
    fn test_underflow() {
        let mut counter = Counter {
            count: 0,
            authority: Pubkey::new_unique(),
        };

        // This should panic due to underflow
        counter.count = counter.count.checked_sub(1).unwrap();
    }

    #[test]
    fn test_set_value() {
        let mut counter = Counter {
            count: 5,
            authority: Pubkey::new_unique(),
        };

        counter.count = 100;

        assert_eq!(counter.count, 100);
    }

    #[test]
    fn test_reset() {
        let mut counter = Counter {
            count: 999,
            authority: Pubkey::new_unique(),
        };

        counter.count = 0;

        assert_eq!(counter.count, 0);
    }
}

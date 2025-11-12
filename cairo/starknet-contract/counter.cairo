// Cairo Smart Contract for StarkNet
// A simple counter contract demonstrating Cairo syntax and StarkNet capabilities

#[starknet::contract]
mod Counter {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        counter: u128,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
        CounterDecreased: CounterDecreased,
        CounterReset: CounterReset,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        #[key]
        value: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecreased {
        #[key]
        value: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterReset {
        #[key]
        by: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u128) {
        self.counter.write(initial_value);
        self.owner.write(get_caller_address());
    }

    #[external(v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        // Increment the counter by 1
        fn increment(ref self: ContractState) {
            let current = self.counter.read();
            self.counter.write(current + 1);
            self.emit(Event::CounterIncreased(CounterIncreased { value: current + 1 }));
        }

        // Decrement the counter by 1
        fn decrement(ref self: ContractState) {
            let current = self.counter.read();
            assert(current > 0, 'Counter cannot be negative');
            self.counter.write(current - 1);
            self.emit(Event::CounterDecreased(CounterDecreased { value: current - 1 }));
        }

        // Get current counter value
        fn get_counter(self: @ContractState) -> u128 {
            self.counter.read()
        }

        // Reset counter to zero (only owner)
        fn reset(ref self: ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Only owner can reset');
            self.counter.write(0);
            self.emit(Event::CounterReset(CounterReset { by: caller }));
        }

        // Get contract owner
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }
}

#[starknet::interface]
trait ICounter<TContractState> {
    fn increment(ref self: TContractState);
    fn decrement(ref self: TContractState);
    fn get_counter(self: @TContractState) -> u128;
    fn reset(ref self: TContractState);
    fn get_owner(self: @TContractState) -> starknet::ContractAddress;
}

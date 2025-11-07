/// Simple Token Module - A basic fungible token implementation on Aptos
/// Demonstrates Move language features and Aptos token standard
module simple_token::simple_token {
    use std::signer;
    use std::string::{Self, String};
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;

    /// Error codes
    const E_NOT_OWNER: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_ALREADY_INITIALIZED: u64 = 3;
    const E_NOT_INITIALIZED: u64 = 4;

    /// Token metadata struct
    struct SimpleToken has key, store {
        name: String,
        symbol: String,
        decimals: u8,
        total_supply: u64,
    }

    /// Token capabilities stored with the owner
    struct TokenCapabilities has key {
        mint_cap: coin::MintCapability<SimpleToken>,
        burn_cap: coin::BurnCapability<SimpleToken>,
        freeze_cap: coin::FreezeCapability<SimpleToken>,
    }

    /// Event emitted when tokens are minted
    struct MintEvent has drop, store {
        recipient: address,
        amount: u64,
    }

    /// Event emitted when tokens are burned
    struct BurnEvent has drop, store {
        from: address,
        amount: u64,
    }

    /// Event handles for tracking token operations
    struct TokenEvents has key {
        mint_events: EventHandle<MintEvent>,
        burn_events: EventHandle<BurnEvent>,
    }

    /// Initialize the token with metadata
    /// Can only be called once by the module publisher
    public entry fun initialize(
        account: &signer,
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        initial_supply: u64,
    ) {
        let account_addr = signer::address_of(account);

        // Ensure not already initialized
        assert!(!exists<TokenCapabilities>(account_addr), E_ALREADY_INITIALIZED);

        // Create the token with Aptos coin framework
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<SimpleToken>(
            account,
            string::utf8(name),
            string::utf8(symbol),
            decimals,
            true, // monitor_supply
        );

        // Store capabilities
        move_to(account, TokenCapabilities {
            mint_cap,
            burn_cap,
            freeze_cap,
        });

        // Store token metadata
        move_to(account, SimpleToken {
            name: string::utf8(name),
            symbol: string::utf8(symbol),
            decimals,
            total_supply: initial_supply,
        });

        // Initialize event handles
        move_to(account, TokenEvents {
            mint_events: account::new_event_handle<MintEvent>(account),
            burn_events: account::new_event_handle<BurnEvent>(account),
        });

        // Mint initial supply to the creator
        if (initial_supply > 0) {
            mint_internal(account, account_addr, initial_supply);
        };
    }

    /// Mint new tokens to a recipient
    /// Only the token owner can mint
    public entry fun mint(
        owner: &signer,
        recipient: address,
        amount: u64
    ) acquires TokenCapabilities, TokenEvents, SimpleToken {
        let owner_addr = signer::address_of(owner);
        assert!(exists<TokenCapabilities>(owner_addr), E_NOT_INITIALIZED);

        mint_internal(owner, recipient, amount);
    }

    /// Internal mint function
    fun mint_internal(
        owner: &signer,
        recipient: address,
        amount: u64
    ) acquires TokenCapabilities, TokenEvents, SimpleToken {
        let owner_addr = signer::address_of(owner);

        // Get mint capability
        let caps = borrow_global<TokenCapabilities>(owner_addr);
        let coins = coin::mint<SimpleToken>(amount, &caps.mint_cap);

        // Register recipient if not already registered
        if (!coin::is_account_registered<SimpleToken>(recipient)) {
            coin::register<SimpleToken>(&account::create_signer_for_test(recipient));
        };

        // Deposit minted tokens
        coin::deposit(recipient, coins);

        // Update total supply
        let token = borrow_global_mut<SimpleToken>(owner_addr);
        token.total_supply = token.total_supply + amount;

        // Emit event
        let events = borrow_global_mut<TokenEvents>(owner_addr);
        event::emit_event(&mut events.mint_events, MintEvent {
            recipient,
            amount,
        });
    }

    /// Burn tokens from the caller's account
    public entry fun burn(
        account: &signer,
        amount: u64
    ) acquires TokenCapabilities, TokenEvents, SimpleToken {
        let account_addr = signer::address_of(account);

        // Check balance
        let balance = coin::balance<SimpleToken>(account_addr);
        assert!(balance >= amount, E_INSUFFICIENT_BALANCE);

        // Find token owner (assumes owner is the first address)
        // In production, you'd store this reference
        let owner_addr = @simple_token;
        let caps = borrow_global<TokenCapabilities>(owner_addr);

        // Withdraw and burn
        let coins = coin::withdraw<SimpleToken>(account, amount);
        coin::burn(coins, &caps.burn_cap);

        // Update total supply
        let token = borrow_global_mut<SimpleToken>(owner_addr);
        token.total_supply = token.total_supply - amount;

        // Emit event
        let events = borrow_global_mut<TokenEvents>(owner_addr);
        event::emit_event(&mut events.burn_events, BurnEvent {
            from: account_addr,
            amount,
        });
    }

    /// Transfer tokens between accounts
    public entry fun transfer(
        from: &signer,
        to: address,
        amount: u64
    ) {
        coin::transfer<SimpleToken>(from, to, amount);
    }

    /// Get token balance of an account
    #[view]
    public fun balance_of(account: address): u64 {
        coin::balance<SimpleToken>(account)
    }

    /// Get total supply
    #[view]
    public fun total_supply(owner: address): u64 acquires SimpleToken {
        if (exists<SimpleToken>(owner)) {
            let token = borrow_global<SimpleToken>(owner);
            token.total_supply
        } else {
            0
        }
    }

    /// Get token metadata
    #[view]
    public fun get_metadata(owner: address): (String, String, u8) acquires SimpleToken {
        let token = borrow_global<SimpleToken>(owner);
        (token.name, token.symbol, token.decimals)
    }

    // ===== Tests =====

    #[test(owner = @simple_token)]
    public fun test_initialize(owner: &signer) {
        initialize(
            owner,
            b"Test Token",
            b"TEST",
            8,
            1000000
        );
    }

    #[test(owner = @simple_token, user = @0x123)]
    public fun test_mint(owner: &signer, user: &signer) acquires TokenCapabilities, TokenEvents, SimpleToken {
        let user_addr = signer::address_of(user);

        initialize(owner, b"Test Token", b"TEST", 8, 0);
        mint(owner, user_addr, 1000);

        assert!(balance_of(user_addr) == 1000, 0);
    }
}

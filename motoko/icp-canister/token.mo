// Motoko Token Canister for DFINITY Internet Computer
// Simple fungible token implementation with DIP20-like interface

import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Time "mo:base/Time";

actor Token {
    // Types
    public type TxRecord = {
        caller: Principal;
        op: Text; // "mint", "burn", "transfer"
        from: Principal;
        to: Principal;
        amount: Nat;
        timestamp: Time.Time;
    };

    public type Metadata = {
        name: Text;
        symbol: Text;
        decimals: Nat8;
        totalSupply: Nat;
        owner: Principal;
        fee: Nat;
    };

    // State variables
    private stable var name_ : Text = "Internet Computer Token";
    private stable var symbol_ : Text = "ICT";
    private stable var decimals_ : Nat8 = 8;
    private stable var totalSupply_ : Nat = 0;
    private stable var owner_ : Principal = Principal.fromText("aaaaa-aa");
    private stable var fee_ : Nat = 0;

    // Stable storage
    private stable var balanceEntries : [(Principal, Nat)] = [];
    private stable var allowanceEntries : [((Principal, Principal), Nat)] = [];
    private stable var txHistory : [TxRecord] = [];

    // Runtime state
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
    private var allowances = HashMap.HashMap<(Principal, Principal), Nat>(1, func(x, y) { Principal.equal(x.0, y.0) and Principal.equal(x.1, y.1) }, func(x) { Principal.hash(x.0) });

    // System functions
    system func preupgrade() {
        balanceEntries := Iter.toArray(balances.entries());
        allowanceEntries := Iter.toArray(allowances.entries());
    };

    system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        balanceEntries := [];

        allowances := HashMap.fromIter<(Principal, Principal), Nat>(
            allowanceEntries.vals(),
            1,
            func(x, y) { Principal.equal(x.0, y.0) and Principal.equal(x.1, y.1) },
            func(x) { Principal.hash(x.0) }
        );
        allowanceEntries := [];
    };

    // Initialize token
    public shared(msg) func init(name: Text, symbol: Text, decimals: Nat8, initialSupply: Nat) : async () {
        if (not Principal.equal(owner_, Principal.fromText("aaaaa-aa"))) {
            return; // Already initialized
        };

        owner_ := msg.caller;
        name_ := name;
        symbol_ := symbol;
        decimals_ := decimals;
        totalSupply_ := initialSupply;

        balances.put(msg.caller, initialSupply);

        let record : TxRecord = {
            caller = msg.caller;
            op = "mint";
            from = Principal.fromText("aaaaa-aa");
            to = msg.caller;
            amount = initialSupply;
            timestamp = Time.now();
        };
        txHistory := Array.append(txHistory, [record]);
    };

    // Query functions
    public query func name() : async Text { name_ };
    public query func symbol() : async Text { symbol_ };
    public query func decimals() : async Nat8 { decimals_ };
    public query func totalSupply() : async Nat { totalSupply_ };
    public query func owner() : async Principal { owner_ };
    public query func fee() : async Nat { fee_ };

    public query func balanceOf(who: Principal) : async Nat {
        switch (balances.get(who)) {
            case null { 0 };
            case (?balance) { balance };
        }
    };

    public query func allowance(owner: Principal, spender: Principal) : async Nat {
        switch (allowances.get((owner, spender))) {
            case null { 0 };
            case (?allowance) { allowance };
        }
    };

    public query func getMetadata() : async Metadata {
        {
            name = name_;
            symbol = symbol_;
            decimals = decimals_;
            totalSupply = totalSupply_;
            owner = owner_;
            fee = fee_;
        }
    };

    // Transfer tokens
    public shared(msg) func transfer(to: Principal, amount: Nat) : async Result.Result<Nat, Text> {
        let from = msg.caller;
        let fromBalance = _balanceOf(from);

        if (fromBalance < amount) {
            return #err("Insufficient balance");
        };

        let toBalance = _balanceOf(to);

        balances.put(from, fromBalance - amount);
        balances.put(to, toBalance + amount);

        let record : TxRecord = {
            caller = msg.caller;
            op = "transfer";
            from = from;
            to = to;
            amount = amount;
            timestamp = Time.now();
        };
        txHistory := Array.append(txHistory, [record]);

        #ok(0)
    };

    // Transfer from (with allowance)
    public shared(msg) func transferFrom(from: Principal, to: Principal, amount: Nat) : async Result.Result<Nat, Text> {
        let caller = msg.caller;
        let fromAllowance = _allowance(from, caller);

        if (fromAllowance < amount) {
            return #err("Insufficient allowance");
        };

        let fromBalance = _balanceOf(from);
        if (fromBalance < amount) {
            return #err("Insufficient balance");
        };

        allowances.put((from, caller), fromAllowance - amount);
        balances.put(from, fromBalance - amount);
        balances.put(to, _balanceOf(to) + amount);

        let record : TxRecord = {
            caller = caller;
            op = "transfer";
            from = from;
            to = to;
            amount = amount;
            timestamp = Time.now();
        };
        txHistory := Array.append(txHistory, [record]);

        #ok(0)
    };

    // Approve spender
    public shared(msg) func approve(spender: Principal, amount: Nat) : async Result.Result<Nat, Text> {
        allowances.put((msg.caller, spender), amount);
        #ok(0)
    };

    // Mint new tokens (owner only)
    public shared(msg) func mint(to: Principal, amount: Nat) : async Result.Result<Nat, Text> {
        if (not Principal.equal(msg.caller, owner_)) {
            return #err("Only owner can mint");
        };

        let toBalance = _balanceOf(to);
        balances.put(to, toBalance + amount);
        totalSupply_ += amount;

        let record : TxRecord = {
            caller = msg.caller;
            op = "mint";
            from = Principal.fromText("aaaaa-aa");
            to = to;
            amount = amount;
            timestamp = Time.now();
        };
        txHistory := Array.append(txHistory, [record]);

        #ok(0)
    };

    // Burn tokens
    public shared(msg) func burn(amount: Nat) : async Result.Result<Nat, Text> {
        let balance = _balanceOf(msg.caller);

        if (balance < amount) {
            return #err("Insufficient balance");
        };

        balances.put(msg.caller, balance - amount);
        totalSupply_ -= amount;

        let record : TxRecord = {
            caller = msg.caller;
            op = "burn";
            from = msg.caller;
            to = Principal.fromText("aaaaa-aa");
            amount = amount;
            timestamp = Time.now();
        };
        txHistory := Array.append(txHistory, [record]);

        #ok(0)
    };

    // Get transaction history
    public query func getTransactionHistory() : async [TxRecord] {
        txHistory
    };

    // Private helper functions
    private func _balanceOf(who: Principal) : Nat {
        switch (balances.get(who)) {
            case null { 0 };
            case (?balance) { balance };
        }
    };

    private func _allowance(owner: Principal, spender: Principal) : Nat {
        switch (allowances.get((owner, spender))) {
            case null { 0 };
            case (?allowance) { allowance };
        }
    };
}

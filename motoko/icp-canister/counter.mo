// Motoko Smart Contract for DFINITY Internet Computer
// Counter canister with persistence and access control

import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Time "mo:base/Time";

actor Counter {
    // State variables
    private stable var counter : Int = 0;
    private stable var owner : Principal = Principal.fromText("aaaaa-aa");
    private stable var totalIncrements : Nat = 0;

    // Stable storage for user increments
    private stable var userIncrementsEntries : [(Principal, Nat)] = [];

    // User increments map
    private var userIncrements = HashMap.HashMap<Principal, Nat>(
        10,
        Principal.equal,
        Principal.hash
    );

    // Event types
    type Event = {
        #Incremented : { by: Principal; value: Int };
        #Decremented : { by: Principal; value: Int };
        #Reset : { by: Principal };
    };

    // Event log
    private stable var eventLog : [Event] = [];

    // System functions for upgrades
    system func preupgrade() {
        userIncrementsEntries := Iter.toArray(userIncrements.entries());
    };

    system func postupgrade() {
        userIncrements := HashMap.fromIter<Principal, Nat>(
            userIncrementsEntries.vals(),
            10,
            Principal.equal,
            Principal.hash
        );
        userIncrementsEntries := [];
    };

    // Initialize owner on first deployment
    public shared(msg) func init() : async () {
        if (Principal.equal(owner, Principal.fromText("aaaaa-aa"))) {
            owner := msg.caller;
        };
    };

    // Get current counter value
    public query func get() : async Int {
        counter
    };

    // Get counter owner
    public query func getOwner() : async Principal {
        owner
    };

    // Get total number of increments
    public query func getTotalIncrements() : async Nat {
        totalIncrements
    };

    // Get user increment count
    public query func getUserIncrements(user: Principal) : async Nat {
        switch (userIncrements.get(user)) {
            case null { 0 };
            case (?count) { count };
        }
    };

    // Increment counter by 1
    public shared(msg) func increment() : async Int {
        counter += 1;
        totalIncrements += 1;

        // Update user increments
        let userCount = switch (userIncrements.get(msg.caller)) {
            case null { 0 };
            case (?count) { count };
        };
        userIncrements.put(msg.caller, userCount + 1);

        // Log event
        let event : Event = #Incremented({
            by = msg.caller;
            value = counter;
        });
        eventLog := Array.append(eventLog, [event]);

        counter
    };

    // Decrement counter by 1
    public shared(msg) func decrement() : async ?Int {
        if (counter <= 0) {
            return null; // Cannot go below zero
        };

        counter -= 1;

        // Log event
        let event : Event = #Decremented({
            by = msg.caller;
            value = counter;
        });
        eventLog := Array.append(eventLog, [event]);

        ?counter
    };

    // Increment by custom amount
    public shared(msg) func incrementBy(amount: Nat) : async Int {
        counter += amount;
        totalIncrements += amount;

        ?counter
    };

    // Reset counter to zero (owner only)
    public shared(msg) func reset() : async ?Int {
        if (not Principal.equal(msg.caller, owner)) {
            return null; // Only owner can reset
        };

        counter := 0;

        // Log event
        let event : Event = #Reset({
            by = msg.caller;
        });
        eventLog := Array.append(eventLog, [event]);

        ?0
    };

    // Set counter to specific value (owner only)
    public shared(msg) func setCounter(value: Int) : async ?Int {
        if (not Principal.equal(msg.caller, owner)) {
            return null; // Only owner can set
        };

        counter := value;
        ?counter
    };

    // Get recent events (last 10)
    public query func getRecentEvents() : async [Event] {
        let size = eventLog.size();
        if (size <= 10) {
            return eventLog;
        };

        let start = size - 10;
        Array.tabulate<Event>(10, func(i) { eventLog[start + i] })
    };

    // Get all events
    public query func getAllEvents() : async [Event] {
        eventLog
    };

    // Clear event log (owner only)
    public shared(msg) func clearEvents() : async Bool {
        if (not Principal.equal(msg.caller, owner)) {
            return false;
        };

        eventLog := [];
        true
    };
}

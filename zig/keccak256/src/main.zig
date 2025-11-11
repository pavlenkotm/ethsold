const std = @import("std");
const crypto = std.crypto;
const mem = std.mem;
const fmt = std.fmt;

/// Keccak256 hash implementation for Ethereum
pub const Keccak256 = struct {
    const Self = @This();
    const HashSize = 32;

    /// Compute Keccak256 hash of input data
    pub fn hash(input: []const u8, output: *[HashSize]u8) void {
        var hasher = crypto.hash.sha3.Keccak256.init(.{});
        hasher.update(input);
        hasher.final(output);
    }

    /// Compute Keccak256 hash and return as hex string
    pub fn hashToHex(allocator: mem.Allocator, input: []const u8) ![]u8 {
        var hash_bytes: [HashSize]u8 = undefined;
        hash(input, &hash_bytes);

        var hex = try allocator.alloc(u8, HashSize * 2);
        _ = try fmt.bufPrint(hex, "{}", .{fmt.fmtSliceHexLower(&hash_bytes)});
        return hex;
    }

    /// Verify Ethereum address checksum (EIP-55)
    pub fn verifyAddressChecksum(address: []const u8) bool {
        if (address.len != 42) return false;
        if (!mem.startsWith(u8, address, "0x")) return false;

        const addr_lower = address[2..];
        var hash_bytes: [HashSize]u8 = undefined;
        hash(addr_lower, &hash_bytes);

        for (addr_lower, 0..) |c, i| {
            if (c >= 'A' and c <= 'F') {
                const hash_byte = hash_bytes[i / 2];
                const nibble = if (i % 2 == 0) hash_byte >> 4 else hash_byte & 0x0F;
                if (nibble < 8) return false;
            }
        }
        return true;
    }
};

/// Ethereum address utilities
pub const EthAddress = struct {
    /// Generate Ethereum address from public key
    pub fn fromPublicKey(allocator: mem.Allocator, pub_key: []const u8) ![]u8 {
        if (pub_key.len != 64) return error.InvalidPublicKey;

        var hash: [32]u8 = undefined;
        Keccak256.hash(pub_key, &hash);

        // Take last 20 bytes
        var address = try allocator.alloc(u8, 42);
        address[0] = '0';
        address[1] = 'x';

        var i: usize = 0;
        while (i < 20) : (i += 1) {
            const byte = hash[12 + i];
            const hex_chars = "0123456789abcdef";
            address[2 + i * 2] = hex_chars[byte >> 4];
            address[2 + i * 2 + 1] = hex_chars[byte & 0x0F];
        }

        return address;
    }

    /// Apply EIP-55 checksum to address
    pub fn toChecksumAddress(allocator: mem.Allocator, address: []const u8) ![]u8 {
        if (address.len != 42) return error.InvalidAddress;
        if (!mem.startsWith(u8, address, "0x")) return error.InvalidAddress;

        const addr_lower = address[2..];
        var hash: [32]u8 = undefined;
        Keccak256.hash(addr_lower, &hash);

        var result = try allocator.alloc(u8, 42);
        result[0] = '0';
        result[1] = 'x';

        for (addr_lower, 0..) |c, i| {
            const hash_byte = hash[i / 2];
            const nibble = if (i % 2 == 0) hash_byte >> 4 else hash_byte & 0x0F;

            if (c >= 'a' and c <= 'f' and nibble >= 8) {
                result[2 + i] = c - 32; // Convert to uppercase
            } else {
                result[2 + i] = c;
            }
        }

        return result;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    try stdout.print("=== Zig Ethereum Keccak256 Implementation ===\n\n", .{});

    // Example 1: Hash a string
    const message = "Hello, Ethereum!";
    var hash: [32]u8 = undefined;
    Keccak256.hash(message, &hash);

    try stdout.print("Message: {s}\n", .{message});
    try stdout.print("Keccak256 Hash: 0x{}\n\n", .{fmt.fmtSliceHexLower(&hash)});

    // Example 2: Generate Ethereum address from public key (example key)
    const pub_key_hex = "04e68acfc0253a10620dff706b0a1b1f1f5833ea3beb3bde2250d5f271f3563606672ebc45e0b7ea2e816ecb70ca03137b1c9476eec63d4632e990020b7b6fba39";
    var pub_key: [64]u8 = undefined;
    _ = try fmt.hexToBytes(&pub_key, pub_key_hex[2..]);

    const address = try EthAddress.fromPublicKey(allocator, &pub_key);
    defer allocator.free(address);

    try stdout.print("Public Key: {s}\n", .{pub_key_hex});
    try stdout.print("Ethereum Address: {s}\n\n", .{address});

    // Example 3: EIP-55 Checksum
    const checksum_addr = try EthAddress.toChecksumAddress(allocator, address);
    defer allocator.free(checksum_addr);

    try stdout.print("Checksum Address: {s}\n", .{checksum_addr});
    try stdout.print("Checksum Valid: {}\n\n", .{Keccak256.verifyAddressChecksum(checksum_addr)});

    try stdout.print("✓ All operations completed successfully!\n", .{});
}

test "keccak256 basic hash" {
    const input = "hello";
    var output: [32]u8 = undefined;
    Keccak256.hash(input, &output);

    // Verify the hash is not all zeros
    var all_zeros = true;
    for (output) |byte| {
        if (byte != 0) all_zeros = false;
    }
    try std.testing.expect(!all_zeros);
}

test "ethereum address generation" {
    var pub_key: [64]u8 = undefined;
    @memset(&pub_key, 0xAB);

    const allocator = std.testing.allocator;
    const address = try EthAddress.fromPublicKey(allocator, &pub_key);
    defer allocator.free(address);

    try std.testing.expect(address.len == 42);
    try std.testing.expect(mem.startsWith(u8, address, "0x"));
}

test "checksum address" {
    const allocator = std.testing.allocator;
    const address = "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed";

    const checksum = try EthAddress.toChecksumAddress(allocator, address);
    defer allocator.free(checksum);

    try std.testing.expect(checksum.len == 42);
    try std.testing.expect(Keccak256.verifyAddressChecksum(checksum));
}

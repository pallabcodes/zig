const std = @import("std");

/// L7 Insight: Defensive Programming via Fuzzing
/// 
/// At Google-scale, code must handle malformed input gracefully.
/// Zig's `zig test` can be integrated with libFuzzer.
/// 
/// A "fuzz target" is a function that takes a slice of bytes and attempts 
/// to process it. Any crash or safety violation is caught by the fuzzer.

pub fn fuzzTarget(data: []const u8) void {
    // Imagine this is a parser for a complex binary format.
    if (data.len < 4) return;
    
    // A classic buffer overflow or out-of-bounds error would be caught here.
    const magic = std.mem.readInt(u32, data[0..4], .little);
    if (magic == 0xDEADBEEF) {
        // Complex logic that might have bugs
        if (data.len > 10) {
            _ = data[10];
        }
    }
}

pub fn demonstrateFuzzing() void {
    std.debug.print("\n--- Fuzzing Strategy ---\n", .{});
    std.debug.print("L7 Pattern: Implement a 'fuzzTarget([]const u8)' function.\n", .{});
    std.debug.print("Use 'zig test --fuzz' (or equivalent wrapper) to feed random bytes.\n", .{});
    
    // Simulating a fuzzing run
    const inputs = [_][]const u8{
        "abc",
        "\xEF\xBE\xAD\xDE",
        "\xEF\xBE\xAD\xDElonginputstring",
    };
    
    for (inputs) |input| {
        fuzzTarget(input);
    }
    std.debug.print("Processed {d} simulated fuzz inputs safely.\n", .{inputs.len});
}

// In a real project, you would have a separate file for the libFuzzer entry point.
// export fn LLVMFuzzerTestOneInput(data: [*]const u8, len: usize) i32 {
//     fuzzTarget(data[0..len]);
//     return 0;
// }

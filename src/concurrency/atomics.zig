const std = @import("std");
const Atomic = std.atomic.Value;

/// L7 Insight: Lock-Free Programming and Memory Ordering
/// 
/// In C++11, `std::atomic` is powerful but can be opaque.
/// Zig's `std.atomic.Value` provides a clean interface to hardware primitives.
/// For systems engineers, the "ordering" parameter is the most critical part.
pub fn demonstrateAtomics() !void {
    std.debug.print("\n--- Concurrency & Atomics ---\n", .{});

    // We use a simple counter shared between "threads" (simulated or real).
    var counter = Atomic(u32).init(0);

    // 1. Monotonic increment (Fetch-Add)
    // .monotonic is enough if we only care about the final value and not ordering
    // relative to other memory operations.
    _ = counter.fetchAdd(1, .monotonic);
    _ = counter.fetchAdd(1, .monotonic);

    std.debug.print("Atomic counter value: {d}\n", .{counter.load(.monotonic)});

    // 2. Compare and Swap (CAS)
    // The building block of lock-free data structures.
    const expected = 2;
    const new_value = 100;
    
    // tryCompareAndSwap returns the old value if it fails.
    if (counter.cmpxchgStrong(expected, new_value, .seq_cst, .seq_cst)) |_| {
        std.debug.print("CAS failed: value was not {d}\n", .{expected});
    } else {
        std.debug.print("CAS succeeded: value is now {d}\n", .{counter.load(.seq_cst)});
    }

    std.debug.print("L7 Note: Use .seq_cst (Sequentially Consistent) for safety, but .acquire/.release for performance.\n", .{});
}

test "atomic basic" {
    var val = Atomic(i32).init(0);
    _ = val.fetchAdd(5, .monotonic);
    try std.testing.expectEqual(@as(i32, 5), val.load(.monotonic));
}

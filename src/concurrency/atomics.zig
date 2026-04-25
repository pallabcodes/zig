const std = @import("std");
const Atomic = std.atomic.Value;

/// L7 Insight: Lock-Free SPSC Queue
/// A wait-free ring buffer demonstrating proper memory ordering.
/// .release is used when publishing data to ensure preceding writes are visible.
/// .acquire is used when consuming to ensure subsequent reads see the published data.
pub fn SpscQueue(comptime T: type, comptime capacity: usize) type {
    return struct {
        buffer: [capacity]T = undefined,
        head: Atomic(usize) = Atomic(usize).init(0),
        tail: Atomic(usize) = Atomic(usize).init(0),

        const Self = @This();

        pub fn push(self: *Self, value: T) bool {
            const current_tail = self.tail.load(.monotonic);
            const next_tail = (current_tail + 1) % capacity;
            
            if (next_tail == self.head.load(.acquire)) {
                return false; // Queue full
            }
            
            self.buffer[current_tail] = value;
            self.tail.store(next_tail, .release); // Publish
            return true;
        }

        pub fn pop(self: *Self) ?T {
            const current_head = self.head.load(.monotonic);
            
            if (current_head == self.tail.load(.acquire)) {
                return null; // Queue empty
            }
            
            const value = self.buffer[current_head];
            self.head.store((current_head + 1) % capacity, .release);
            return value;
        }
    };
}

pub fn demonstrateAtomics() !void {
    std.debug.print("\n--- Concurrency: Lock-Free SPSC Queue ---\n", .{});
    
    var queue = SpscQueue(u32, 4){};
    
    _ = queue.push(100);
    _ = queue.push(200);
    
    std.debug.print("Popped: {?d}\n", .{queue.pop()});
    std.debug.print("Popped: {?d}\n", .{queue.pop()});
    std.debug.print("Popped (empty): {?d}\n", .{queue.pop()});
}

test "spsc queue" {
    var q = SpscQueue(u32, 3){};
    try std.testing.expect(q.push(1));
    try std.testing.expect(q.push(2));
    try std.testing.expect(!q.push(3)); // Full, capacity is 3, holds max 2
    
    try std.testing.expectEqual(@as(?u32, 1), q.pop());
    try std.testing.expectEqual(@as(?u32, 2), q.pop());
    try std.testing.expectEqual(@as(?u32, null), q.pop());
}

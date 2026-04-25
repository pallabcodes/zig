const std = @import("std");

/// L7 Insight: State-Machine Generators
/// Because native `async` is disabled in Zig 0.16.0, systems engineers must
/// implement pausable, interruptible streams manually via state machines.
/// This struct acts as an asynchronous sequence generator.
pub const FibonacciStream = struct {
    state: State,
    a: u64,
    b: u64,
    max: u64,

    const State = enum { Init, Running, Paused, Done };

    pub fn init(max: u64) FibonacciStream {
        return .{ .state = .Init, .a = 0, .b = 1, .max = max };
    }

    /// Simulates advancing an async stream. It can yield a value, pause, or return null when done.
    pub fn next(self: *FibonacciStream) ?u64 {
        switch (self.state) {
            .Init => {
                self.state = .Running;
                return self.a; // Yield 0
            },
            .Running => {
                if (self.b > self.max) {
                    self.state = .Done;
                    return null;
                }
                const next_val = self.b;
                self.b = self.a + self.b;
                self.a = next_val;
                
                // Simulate backpressure/pausing based on some arbitrary system condition
                if (next_val % 2 == 0) {
                    self.state = .Paused;
                }
                return next_val;
            },
            .Paused => {
                // The caller (e.g. event loop) must explicitly resume the stream
                std.debug.print("  [Stream Paused (Backpressure)] -> Resuming...\n", .{});
                self.state = .Running;
                return self.next();
            },
            .Done => return null,
        }
    }
};

pub fn demonstrateStreams() void {
    std.debug.print("\n--- Streams: Pausable State-Machine Generator ---\n", .{});
    
    var stream = FibonacciStream.init(50);
    
    while (stream.next()) |val| {
        std.debug.print("Stream yielded: {d}\n", .{val});
    }
}

test "state machine stream" {
    var stream = FibonacciStream.init(3);
    try std.testing.expectEqual(@as(?u64, 0), stream.next());
    try std.testing.expectEqual(@as(?u64, 1), stream.next());
    try std.testing.expectEqual(@as(?u64, 1), stream.next());
    try std.testing.expectEqual(@as(?u64, 2), stream.next()); // Will hit pause state next
    try std.testing.expectEqual(@as(?u64, 3), stream.next());
    try std.testing.expectEqual(@as(?u64, null), stream.next());
}

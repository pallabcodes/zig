const std = @import("std");

/// L7 Insight: Generics are just functions.
/// 
/// In C++, templates are a separate language (SFINAE, concepts, etc.).
/// In Zig, a "generic" is just a function that takes a `type` and returns a `type`.
/// This happens at `comptime`.
pub fn GenericStack(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        count: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            return .{
                .items = try allocator.alloc(T, capacity),
                .count = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, item: T) !void {
            if (self.count >= self.items.len) return error.StackFull;
            self.items[self.count] = item;
            self.count += 1;
        }
    };
}

pub fn demonstrateBasics() !void {
    std.debug.print("\n--- Comptime Basics ---\n", .{});

    // We call the function with `u32` to generate a specific stack type.
    const IntStack = GenericStack(u32);
    
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stack = try IntStack.init(allocator, 10);
    defer stack.deinit();

    try stack.push(42);
    try stack.push(1337);

    std.debug.print("Stack count: {d}\n", .{stack.count});
    std.debug.print("Top item: {d}\n", .{stack.items[stack.count - 1]});
}

test "generic stack" {
    const FloatStack = GenericStack(f32);
    var buffer: [128]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    
    var stack = try FloatStack.init(fba.allocator(), 2);
    try stack.push(3.14);
    try std.testing.expect(stack.items[0] == 3.14);
}

const std = @import("std");
const Allocator = std.mem.Allocator;

/// L7 Insight: The Power of Interface-based Allocation
/// 
/// In Zig 0.16.0+, the memory management landscape has been unified.
/// `std.mem.Allocator` is a fat pointer (vtable + context), allowing 
/// functions to be agnostic about the backing storage strategy.
pub fn demonstrateAllocators() !void {
    // 1. DebugAllocator
    // In Zig 0.16.0, GeneralPurposeAllocator has been evolved into DebugAllocator.
    // It is a generic type that takes a Config.
    var debug_alloc = std.heap.DebugAllocator(.{}){};
    defer _ = debug_alloc.deinit(); 
    const allocator = debug_alloc.allocator();

    std.debug.print("\n--- DebugAllocator ---\n", .{});
    const bytes = try allocator.alloc(u8, 100);
    defer allocator.free(bytes);
    std.debug.print("Allocated {d} bytes on the heap using DebugAllocator.\n", .{bytes.len});

    // 2. ArenaAllocator
    // Still the "L7 secret weapon" for request-scoped memory.
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit(); 
    const arena_allocator = arena.allocator();

    std.debug.print("\n--- ArenaAllocator ---\n", .{});
    _ = try arena_allocator.alloc(u8, 10);
    _ = try arena_allocator.alloc(u8, 20);
    std.debug.print("Performed multiple allocations. One defer arena.deinit() handles all.\n", .{});

    // 3. FixedBufferAllocator
    // Zero-syscall allocation using a pre-allocated buffer.
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const fba_allocator = fba.allocator();

    std.debug.print("\n--- FixedBufferAllocator ---\n", .{});
    const stack_bytes = try fba_allocator.alloc(u8, 128);
    std.debug.print("Allocated {d} bytes from a stack buffer. Zero heap overhead.\n", .{stack_bytes.len});
}

test "allocator interface" {
    var buffer: [128]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    try testTarget(fba.allocator());
}

fn testTarget(allocator: Allocator) !void {
    const data = try allocator.alloc(u32, 5);
    defer allocator.free(data);
    std.debug.assert(data.len == 5);
}

const std = @import("std");

/// L7 Insight: Data-Oriented Design (DoD)
/// 
/// Most languages focus on Object-Oriented Design (AoS - Array of Structures).
/// High-performance systems use SoA (Structure of Arrays).
/// 
/// AoS: [ {x,y,z}, {x,y,z}, {x,y,z} ] -> Cache-unfriendly for partial updates.
/// SoA: { [x,x,x], [y,y,y], [z,z,z] } -> CPU-prefetcher's dream.
pub fn demonstrateSoA() !void {
    std.debug.print("\n--- Structure of Arrays (SoA) ---\n", .{});

    const Particle = struct {
        x: f32,
        y: f32,
        z: f32,
        mass: f32,
    };

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // MultiArrayList automatically transforms Particle from AoS to SoA at comptime.
    var list = std.MultiArrayList(Particle){};
    defer list.deinit(allocator);

    try list.append(allocator, .{ .x = 1.0, .y = 2.0, .z = 3.0, .mass = 10.0 });
    try list.append(allocator, .{ .x = 4.0, .y = 5.0, .z = 6.0, .mass = 20.0 });

    // We can now access ALL 'x' values as a single contiguous slice.
    // This allows the CPU to process 'x' values in a tight loop with perfect prefetching.
    const x_values = list.slice().items(.x);
    std.debug.print("First particle X: {d:.1}\n", .{x_values[0]});
    std.debug.print("Contiguous 'x' slice length: {d}\n", .{x_values.len});
}

/// L7 Insight: Explicit SIMD (Single Instruction, Multiple Data)
/// 
/// Compilers are good at auto-vectorization, but not perfect.
/// Zig's `@Vector` allows you to write architecture-independent SIMD code.
pub fn demonstrateSIMD() void {
    std.debug.print("\n--- Explicit SIMD ---\n", .{});

    // A vector of 4 floats (128 bits).
    const vec_a: @Vector(4, f32) = .{ 1.0, 2.0, 3.0, 4.0 };
    const vec_b: @Vector(4, f32) = .{ 5.0, 6.0, 7.0, 8.0 };

    // This performs 4 additions in a single CPU instruction (e.g., ADDPS on x86).
    const result = vec_a + vec_b;

    std.debug.print("SIMD Result: {any}\n", .{result});
    
    // Horizontal operations (summing all elements of a vector)
    const sum = @reduce(.Add, result);
    std.debug.print("SIMD Horizontal Sum: {d:.1}\n", .{sum});
}

test "multi_array_list" {
    const T = struct { a: u32, b: u8 };
    var list = std.MultiArrayList(T){};
    defer list.deinit(std.testing.allocator);
    try list.append(std.testing.allocator, .{ .a = 1, .b = 2 });
    try std.testing.expectEqual(@as(u32, 1), list.slice().items(.a)[0]);
}

const std = @import("std");

/// L7 Insight: Zig is a C Compiler.
/// 
/// You don't need a separate build tool to handle C dependencies.
/// Zig can import C headers directly and link against C code with zero overhead.
/// The `extern` keyword defines functions using the C ABI.

// 1. Manual FFI definition (Transparent ABI)
pub extern fn add_in_c(a: i32, b: i32) i32;

pub const CPoint = extern struct {
    x: i32,
    y: i32,
};
pub extern fn sum_point(p: CPoint) i32;

pub fn demonstrateFFI() void {
    std.debug.print("\n--- Zero-Overhead FFI ---\n", .{});

    // Calling the C function directly.
    const result = add_in_c(10, 20);
    std.debug.print("10 + 20 in C is: {d}\n", .{result});

    const p = CPoint{ .x = 100, .y = 200 };
    const point_sum = sum_point(p);
    std.debug.print("Point sum in C is: {d}\n", .{point_sum});

    std.debug.print("FFI works because Zig follows the C ABI exactly.\n", .{});
}

test "ffi basic" {
    // Tests will only work if we link the C file in build.zig for the test runner too.
    const res = add_in_c(1, 2);
    try std.testing.expect(res == 3);
}

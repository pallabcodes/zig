const std = @import("std");

/// L7 Insight: Safety is a First-Class Citizen, not an Afterthought.
/// 
/// In C/C++, Undefined Behavior (UB) is a silent killer.
/// In Zig, many types of UB are caught at runtime in Debug/ReleaseSafe modes.
pub fn demonstrateSafety() void {
    // 1. Integer Overflow
    // In Zig, overflow is illegal. In Debug mode, it triggers a panic.
    // This prevents "wraparound" bugs that cause security vulnerabilities.
    const x: u8 = 255;
    // x += 1; // This would panic at runtime in Debug mode.
    
    // Explicit overflow is allowed via specific operators:
    const wrapped = x +% 1; // Wraparound addition
    _ = wrapped;

    // 2. Optionals (The end of NullPointerException)
    // You cannot have a null pointer in Zig unless the type explicitly allows it.
    const maybe_ptr: ?*usize = null;
    
    // To use it, you MUST unwrap it.
    if (maybe_ptr) |ptr| {
        _ = ptr.*;
    } else {
        // Handle null case
    }

    // 3. Unreachable
    // If you are logically certain a branch can't be hit, use `unreachable`.
    // In Debug, this panics. In ReleaseFast, it's an optimization hint.
    const val: u32 = 10;
    if (val > 100) {
        unreachable;
    }
}

test "integer overflow" {
    // We can use `std.testing.expectError` or just check behavior.
    const x: u8 = 200;
    const result = std.math.add(u8, x, 60);
    try std.testing.expectError(error.Overflow, result);
}

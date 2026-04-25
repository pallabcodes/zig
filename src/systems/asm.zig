const std = @import("std");
const builtin = @import("builtin");

/// L7 Insight: Dropping into the Metal
pub fn demonstrateAsm() void {
    std.debug.print("\n--- Inline Assembly (asm) ---\n", .{});

    // Use builtin.cpu.arch to check architecture at comptime.
    if (builtin.cpu.arch.isX86()) {
        asm volatile ("pause");
        std.debug.print("Executed x86 'pause' instruction.\n", .{});
    }

    if (builtin.cpu.arch.isX86()) {
        var low: u32 = undefined;
        var high: u32 = undefined;
        
        asm volatile ("rdtsc"
            : [low] "={eax}" (low),
              [high] "={edx}" (high),
        );
        
        const cycles = (@as(u64, high) << 32) | low;
        std.debug.print("CPU Cycle Count: {d}\n", .{cycles});
    } else {
        std.debug.print("Assembly example skipped (not x86_64).\n", .{});
    }
}

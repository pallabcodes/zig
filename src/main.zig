const std = @import("std");
const lib = @import("lib");

pub fn main() !void {
    std.debug.print("=== Zig Knowledge Base for L7 Engineers ===\n", .{});
    std.debug.print("Build Time: {s}, Author: {s}\n", .{ lib.version.build_time, lib.version.author });

    // Phase 2: Memory & Safety
    try lib.allocators.demonstrateAllocators();
    lib.safety.demonstrateSafety();

    // Phase 3: Metaprogramming
    try lib.comptime_basics.demonstrateBasics();
    lib.reflection.demonstrateReflection();

    // Phase 4: FFI
    lib.ffi.demonstrateFFI();

    // Phase 5: Systems Primitives
    try lib.atomics.demonstrateAtomics();
    lib.systems.demonstratePacked();

    // Phase 6: High Performance (Google-scale)
    try lib.performance.demonstrateSoA();
    lib.performance.demonstrateSIMD();
    lib.fuzz.demonstrateFuzzing();

    // Phase 7: Kernel & Toolchain (Absolute Zero)
    lib.kernel.demonstrateKernelPattern();
    lib.assembly.demonstrateAsm();

    std.debug.print("\nAll demonstrations completed successfully.\n", .{});
}

test {
    _ = lib;
}

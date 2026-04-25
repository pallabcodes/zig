const std = @import("std");

// Import the module generated at build-time.
pub const version = @import("version");

/// This module explores the philosophy of explicit memory management in Zig.
pub const allocators = @import("memory/allocators.zig");

/// Safety features and UB prevention.
pub const safety = @import("memory/safety.zig");

/// Metaprogramming basics: type functions and comptime variables.
pub const comptime_basics = @import("comptime/basics.zig");

/// Advanced reflection and introspection.
pub const reflection = @import("comptime/reflection.zig");

/// FFI and C interop.
pub const ffi = @import("ffi/c_interop.zig");

/// Concurrency and Atomic primitives.
pub const atomics = @import("concurrency/atomics.zig");

/// Thread Pools and Backpressure.
pub const thread_pool = @import("parallelism/thread_pool.zig");

/// Pausable Streams and Generators.
pub const streams = @import("parallelism/streams.zig");

/// Low-level systems primitives: Packed structs and Tagged unions.
pub const systems = @import("systems/packed.zig");

/// High-performance data patterns: SoA and SIMD.
pub const performance = @import("performance/patterns.zig");

/// Defensive programming: Fuzzing targets.
pub const fuzz = @import("performance/fuzz.zig");

/// Kernel-style patterns (@fieldParentPtr).
pub const kernel = @import("systems/kernel.zig");

/// Inline Assembly.
pub const assembly = @import("systems/asm.zig");

test {
    _ = allocators;
    _ = safety;
    _ = comptime_basics;
    _ = reflection;
    _ = ffi;
    _ = atomics;
    _ = thread_pool;
    _ = streams;
    _ = systems;
    _ = performance;
    _ = fuzz;
    _ = kernel;
    _ = assembly;
}

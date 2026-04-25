# Zig Knowledge Base for Systems Engineers

This repository is a curated, deep-dive into the Zig programming language, designed specifically for L7+ systems engineers who are already proficient in C/C++. 

The goal is to provide a "better than official docs" experience by focusing on the mechanical sympathy, safety guarantees, and metaprogramming power of Zig.

## Why Zig? (The L7 Perspective)

For an engineer coming from C++, Zig represents a "reset" to first principles with modern ergonomics:

1.  **No Hidden Control Flow**: No operator overloading, no hidden constructors/destructors, no exceptions. If you see code, it's exactly what's happening.
2.  **Memory is First-Class**: Zig does not have a global allocator. Every function that needs memory must accept an allocator. This makes resource usage explicit and audit-friendly.
3.  **Comptime is the Killer Feature**: Zig replaces templates, macros, and constexpr with a single, unified mechanism: `comptime`. It's just Zig code running at compile-time.
4.  **Error Handling without Overhead**: Error sets are value-based and handled via `try`/`catch`, providing the safety of exceptions with the performance of return codes.

## Repository Structure

- `src/memory/`: Deep dives into manual memory management, custom allocators, and the `std.mem.Allocator` interface.
- `src/comptime/`: Advanced metaprogramming, reflection, and generic type generation.
- `src/ffi/`: Zero-overhead C interop and ABI stability patterns.
- `src/concurrency/`: Lock-free primitives and hardware-aware synchronization.

## Getting Started

### Prerequisites
- Zig 0.16.0 (Installed in `./bin/zig`)

### Commands
```bash
# Run the demonstration suite
zig build run

# Run all deep-dive tests
zig build test
```

## Curriculum Philosophy
Each module is designed as a standalone "lesson" with extensive commentary on the underlying assembly/memory behavior. We don't just show you *how* to write Zig; we show you *why* it works that way.

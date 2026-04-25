# Project Philosophy & Curriculum

## The L7 Perspective

For an engineer coming from C++, Zig represents a "reset" to first principles with modern ergonomics:

1.  **No Hidden Control Flow**: No operator overloading, no hidden constructors/destructors, no exceptions. If you see code, it's exactly what's happening.
2.  **Memory is First-Class**: Zig does not have a global allocator. Every function that needs memory must accept an allocator. This makes resource usage explicit and audit-friendly.
3.  **Comptime is the Killer Feature**: Zig replaces templates, macros, and constexpr with a single, unified mechanism: `comptime`. It's just Zig code running at compile-time.
4.  **Error Handling without Overhead**: Error sets are value-based and handled via `try`/`catch`, providing the safety of exceptions with the performance of return codes.

## Curriculum Philosophy
Each module is designed as a standalone "lesson" with extensive commentary on the underlying assembly/memory behavior. We don't just show you *how* to write Zig; we show you *why* it works that way.

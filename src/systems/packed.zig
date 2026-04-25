const std = @import("std");

/// L7 Insight: Controlling Memory Layout at the Bit Level
/// 
/// In C, bit-fields are notoriously implementation-defined (endianness, padding).
/// Zig's `packed struct` provides a GUARANTEED layout.
/// This is essential for:
/// - Writing drivers (MMIO)
/// - Network protocol parsers (TCP/IP headers)
/// - Filesystem structures
pub const NetworkHeader = packed struct {
    version: u4,
    ihl: u4,
    tos: u8,
    total_length: u16,
    
    // Zig allows us to verify the size at compile-time.
    comptime {
        // 4+4+8+16 bits = 32 bits = 4 bytes.
        std.debug.assert(@sizeOf(@This()) == 4);
    }
};

/// Tagged Unions: Type Safety with C-Union Performance
/// 
/// A tagged union is a "Sum Type". It stores a tag and one of several values.
/// Zig's tagged unions are "Safe Unions" because the compiler prevents 
/// accessing the wrong field.
pub const Instruction = union(enum) {
    jump: u32,
    move: struct { src: u8, dst: u8 },
    halt,
};

pub fn demonstratePacked() void {
    std.debug.print("\n--- Packed Structs & Tagged Unions ---\n", .{});

    // 1. Packed Struct
    const header = NetworkHeader{
        .version = 4,
        .ihl = 5,
        .tos = 0,
        .total_length = 1500,
    };
    
    // We can cast a packed struct to its underlying integer type to see the raw bits.
    const raw_bits = @as(u32, @bitCast(header));
    std.debug.print("Raw IPv4 header bits (u32): 0x{x}\n", .{raw_bits});

    // 2. Tagged Union
    const inst = Instruction{ .move = .{ .src = 1, .dst = 2 } };
    
    switch (inst) {
        .jump => |addr| std.debug.print("Executing JUMP to 0x{x}\n", .{addr}),
        .move => |m| std.debug.print("Executing MOVE from R{d} to R{d}\n", .{m.src, m.dst}),
        .halt => std.debug.print("Executing HALT\n", .{}),
    }
}

test "packed struct layout" {
    const TestPacked = packed struct {
        a: u1,
        b: u7,
    };
    try std.testing.expectEqual(@as(usize, 1), @sizeOf(TestPacked));
}

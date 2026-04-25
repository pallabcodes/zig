const std = @import("std");

/// L7 Insight: Zero-Cost Comptime Serializer
/// Uses @typeInfo to generate highly optimized, unrolled byte-parsing logic 
/// at compile-time for arbitrary structs, avoiding runtime reflection overhead.
pub fn serialize(comptime T: type, value: T, writer: anytype) !void {
    const info = @typeInfo(T);
    switch (info) {
        .@"struct" => |s| {
            inline for (s.fields) |field| {
                try serialize(field.type, @field(value, field.name), writer);
            }
        },
        .int => {
            try writer.writeInt(T, value, .little);
        },
        .bool => {
            const b: u8 = if (value) 1 else 0;
            try writer.writeInt(u8, b, .little);
        },
        else => @compileError("Unsupported type for serialization: " ++ @typeName(T)),
    }
}

pub fn demonstrateReflection() void {
    std.debug.print("\n--- Comptime: Zero-Cost Serializer ---\n", .{});

    const NetworkHeader = struct {
        magic: u32,
        version: u16,
        is_encrypted: bool,
    };

    const header = NetworkHeader{
        .magic = 0xDEADBEEF,
        .version = 2,
        .is_encrypted = true,
    };

    var buf: [32]u8 = undefined;
    var fba = std.io.fixedBufferStream(&buf);
    
    serialize(NetworkHeader, header, fba.writer()) catch unreachable;
    
    std.debug.print("Serialized output: {x}\n", .{fba.getWritten()});
}

test "comptime serializer" {
    const Point = struct { x: u32, y: u32 };
    const pt = Point{ .x = 10, .y = 20 };
    
    var buf: [8]u8 = undefined;
    var fba = std.io.fixedBufferStream(&buf);
    try serialize(Point, pt, fba.writer());
    
    try std.testing.expectEqualSlices(u8, &[_]u8{ 10, 0, 0, 0, 20, 0, 0, 0 }, fba.getWritten());
}

const std = @import("std");

pub fn printStructFields(comptime T: type, value: T) void {
    const info = @typeInfo(T);

    switch (info) {
        .@"struct" => |s| {
            std.debug.print("Introspecting struct '{s}':\n", .{@typeName(T)});

            inline for (s.fields) |field| {
                const val = @field(value, field.name);
                std.debug.print("  - Field: {s}, Type: {s}, Value: {any}\n", .{
                    field.name,
                    @typeName(field.type),
                    val,
                });
            }
        },
        else => {
            @compileError("printStructFields only works on structs, found " ++ @tagName(info));
        },
    }
}

pub fn demonstrateReflection() void {
    std.debug.print("\n--- Comptime Reflection ---\n", .{});

    const User = struct {
        id: u32,
        name: []const u8,
        active: bool,
    };

    const me = User{
        .id = 1,
        .name = "L7 Engineer",
        .active = true,
    };

    printStructFields(User, me);
}

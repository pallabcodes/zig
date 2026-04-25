const std = @import("std");

/// L7 Insight: The "Container Of" Pattern
/// 
/// In C/C++, implementing interfaces often requires virtual functions (vtable).
/// Zig uses `@fieldParentPtr` to implement interfaces without hidden overhead.
/// This is the exact pattern used by `std.mem.Allocator`.

pub const Writer = struct {
    write_fn: *const fn (context: *anyopaque, data: []const u8) void,
    
    pub fn write(self: *const Writer, data: []const u8) void {
        self.write_fn(@constCast(@ptrCast(self)), data);
    }
};

pub const MyCustomWriter = struct {
    interface: Writer,
    prefix: []const u8,

    pub fn init(prefix: []const u8) MyCustomWriter {
        return .{
            .interface = .{ .write_fn = writeImpl },
            .prefix = prefix,
        };
    }

    fn writeImpl(context: *anyopaque, data: []const u8) void {
        // Correct @fieldParentPtr usage in 0.16.0: @fieldParentPtr("field", ptr)
        const interface_ptr: *const Writer = @alignCast(@ptrCast(context));
        const self: *const MyCustomWriter = @fieldParentPtr("interface", interface_ptr);
        std.debug.print("[{s}] {s}\n", .{ self.prefix, data });
    }
};

pub fn demonstrateKernelPattern() void {
    std.debug.print("\n--- Kernel-Style Interfaces (@fieldParentPtr) ---\n", .{});

    const my_writer = MyCustomWriter.init("L7-DEBUG");
    
    const w = &my_writer.interface;
    w.write("Hello from the kernel pattern!");
}

test "fieldParentPtr basic" {
    const Container = struct {
        a: u32,
        b: u32,
    };
    var c = Container{ .a = 1, .b = 2 };
    const b_ptr = &c.b;
    const c_ptr: *Container = @fieldParentPtr("b", b_ptr);
    try std.testing.expect(c_ptr == &c);
}

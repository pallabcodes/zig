const std = @import("std");
const Allocator = std.mem.Allocator;

/// L7 Insight: Slab Allocator
/// A custom cache-aligned allocator optimized for O(1) allocation/deallocation 
/// of fixed-size objects using a free-list.
pub const SlabAllocator = struct {
    fallback_allocator: Allocator,
    head: ?*Node,
    block_size: usize,

    const Node = struct {
        next: ?*Node,
    };

    pub fn init(fallback: Allocator, comptime T: type) SlabAllocator {
        const size = @max(@sizeOf(T), @sizeOf(Node));
        return SlabAllocator{
            .fallback_allocator = fallback,
            .head = null,
            .block_size = size,
        };
    }

    pub fn allocator(self: *SlabAllocator) Allocator {
        return Allocator{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .remap = remap,
                .free = free,
            },
        };
    }

    fn alloc(ctx: *anyopaque, len: usize, ptr_align: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        const self: *SlabAllocator = @ptrCast(@alignCast(ctx));
        if (len != self.block_size) {
            return self.fallback_allocator.vtable.alloc(self.fallback_allocator.ptr, len, ptr_align, ret_addr);
        }

        if (self.head) |h| {
            self.head = h.next;
            return @ptrCast(h);
        }

        return self.fallback_allocator.vtable.alloc(self.fallback_allocator.ptr, len, ptr_align, ret_addr);
    }

    fn resize(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        const self: *SlabAllocator = @ptrCast(@alignCast(ctx));
        return self.fallback_allocator.vtable.resize(self.fallback_allocator.ptr, buf, buf_align, new_len, ret_addr);
    }

    fn remap(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        const self: *SlabAllocator = @ptrCast(@alignCast(ctx));
        return self.fallback_allocator.vtable.remap(self.fallback_allocator.ptr, memory, alignment, new_len, ret_addr);
    }

    fn free(ctx: *anyopaque, buf: []u8, buf_align: std.mem.Alignment, ret_addr: usize) void {
        const self: *SlabAllocator = @ptrCast(@alignCast(ctx));
        if (buf.len != self.block_size) {
            self.fallback_allocator.vtable.free(self.fallback_allocator.ptr, buf, buf_align, ret_addr);
            return;
        }

        const node: *Node = @ptrCast(@alignCast(buf.ptr));
        node.next = self.head;
        self.head = node;
    }
};

pub fn demonstrateAllocators() !void {
    std.debug.print("\n--- Advanced Memory: Slab Allocator ---\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const Packet = struct { data: [64]u8 };
    var slab = SlabAllocator.init(gpa.allocator(), Packet);
    const alloc = slab.allocator();

    const p1 = try alloc.create(Packet);
    std.debug.print("Allocated Packet at {*}\n", .{p1});
    alloc.destroy(p1);
    
    const p2 = try alloc.create(Packet);
    std.debug.print("Re-allocated Packet at {*}\n", .{p2});
    std.debug.assert(p1 == p2); 
    alloc.destroy(p2);
}

test "slab allocator" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    
    var slab = SlabAllocator.init(gpa.allocator(), u64);
    const alloc = slab.allocator();
    
    const ptr1 = try alloc.create(u64);
    const ptr2 = try alloc.create(u64);
    alloc.destroy(ptr1);
    const ptr3 = try alloc.create(u64);
    try std.testing.expect(ptr1 == ptr3);
    alloc.destroy(ptr2);
    alloc.destroy(ptr3);
}

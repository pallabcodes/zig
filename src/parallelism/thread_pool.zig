const std = @import("std");
const Allocator = std.mem.Allocator;
const Thread = std.Thread;

/// L7 Insight: Backpressured Thread Pool
/// This pool uses a bounded queue. If the queue is full, `submit` will block
/// the caller, naturally applying backpressure to the producer. This is how
/// massive systems handle load shedding.
pub const ThreadPool = struct {
    allocator: Allocator,
    threads: []Thread,
    
    mutex: Thread.Mutex,
    cond_not_full: Thread.Condition,
    cond_not_empty: Thread.Condition,
    
    tasks: []Task,
    head: usize,
    tail: usize,
    count: usize,
    
    is_running: bool,

    const Task = struct {
        runFn: *const fn (ctx: *anyopaque) void,
        ctx: *anyopaque,
    };

    pub fn init(allocator: Allocator, num_threads: usize, queue_capacity: usize) !*ThreadPool {
        const pool = try allocator.create(ThreadPool);
        pool.* = .{
            .allocator = allocator,
            .threads = try allocator.alloc(Thread, num_threads),
            .mutex = .{},
            .cond_not_full = .{},
            .cond_not_empty = .{},
            .tasks = try allocator.alloc(Task, queue_capacity),
            .head = 0,
            .tail = 0,
            .count = 0,
            .is_running = true,
        };

        for (pool.threads) |*th| {
            th.* = try Thread.spawn(.{}, workerLoop, .{pool});
        }

        return pool;
    }

    pub fn deinit(self: *ThreadPool) void {
        self.mutex.lock();
        self.is_running = false;
        self.cond_not_empty.broadcast();
        self.mutex.unlock();

        for (self.threads) |th| {
            th.join();
        }

        self.allocator.free(self.threads);
        self.allocator.free(self.tasks);
        self.allocator.destroy(self);
    }

    /// Submits a task. If the queue is full, this blocks, applying backpressure.
    pub fn submit(self: *ThreadPool, runFn: *const fn (ctx: *anyopaque) void, ctx: *anyopaque) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        while (self.count == self.tasks.len and self.is_running) {
            self.cond_not_full.wait(&self.mutex);
        }

        if (!self.is_running) return;

        self.tasks[self.tail] = .{ .runFn = runFn, .ctx = ctx };
        self.tail = (self.tail + 1) % self.tasks.len;
        self.count += 1;

        self.cond_not_empty.signal();
    }

    fn workerLoop(self: *ThreadPool) void {
        while (true) {
            self.mutex.lock();
            while (self.count == 0 and self.is_running) {
                self.cond_not_empty.wait(&self.mutex);
            }

            if (!self.is_running and self.count == 0) {
                self.mutex.unlock();
                break;
            }

            const task = self.tasks[self.head];
            self.head = (self.head + 1) % self.tasks.len;
            self.count -= 1;
            
            // Signal that there's space (backpressure relief)
            self.cond_not_full.signal(); 
            self.mutex.unlock();

            task.runFn(task.ctx);
        }
    }
};

fn dummyTask(ctx: *anyopaque) void {
    const id: *usize = @ptrCast(@alignCast(ctx));
    std.debug.print("Task {d} executed on thread\n", .{id.*});
}

pub fn demonstrateThreadPool() !void {
    std.debug.print("\n--- Parallelism: Backpressured Thread Pool ---\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // 2 workers, maximum of 4 pending tasks in the backlog
    var pool = try ThreadPool.init(gpa.allocator(), 2, 4); 
    defer pool.deinit();

    var task_ids = [_]usize{ 1, 2, 3, 4, 5, 6 };
    for (&task_ids) |*id| {
        pool.submit(dummyTask, id);
    }
    
    std.time.sleep(10 * std.time.ns_per_ms); // Wait for tasks to flush
}

test "thread pool" {
    var pool = try ThreadPool.init(std.testing.allocator, 2, 2);
    defer pool.deinit();
    
    var id: usize = 42;
    pool.submit(dummyTask, &id);
}

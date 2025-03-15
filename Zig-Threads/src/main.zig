// to run prgm: zig build run
// to run the tests: zig build test
// zig build-exe src/main.zig -O ReleaseFast or ReleaseSafe

// Concurrency:
// Thread pool for parallel execution
// WaitGroup for synchronization
// Mutex for thread safety

const std = @import("std");
const Pool = std.Thread.Pool;
const Timer = std.time.Timer;
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const Mutex = std.Thread.Mutex;
var timer: Timer = undefined;

// Constants for optimization
const PRIMES_IN_10M = 664579; // Number of primes in first 10 million numbers

// Type for chunk of odd numbers to be tested and later deinitialized
const ThreadWorkload = struct {
    numbers: std.ArrayList(u32),

    pub fn deinit(self: *@This()) void {
        self.numbers.deinit();
    }
};

// Prime number checking functions
fn isPrime(number: u32) bool {
    switch (number) {
        0, 1 => return false,
        2 => return true,
        else => {
            if (number % 2 == 0) return false;
            var divisor: u32 = 3;
            while (divisor * divisor <= number) : (divisor += 2) {
                if (number % divisor == 0) return false;
            }
        },
    }
    return true;
}

// User input handling functions
fn userNumberInput(prompt: []const u8) !u32 {
    var buffer: [10]u8 = undefined;
    try stdout.print("\n{s}", .{prompt});
    if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |user_input| {
        return try std.fmt.parseInt(u32, user_input, 10);
    }
    return 0;
}

fn userResponseYN(prompt: []const u8) !bool {
    var buffer: [10]u8 = undefined;
    try stdout.print("{s}", .{prompt});
    if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |response| {
        return std.mem.eql(u8, "y", response);
    }
    try stdout.print("Error: failed to parse response\n", .{});
    return false;
}

// Workload creation functions
// Create a number range of odd numbers in the given range
fn createNumberRange(allocator: std.mem.Allocator, start: u32, end: u32) !std.ArrayList(u32) {
    // Calculate approximate capacity (half the range for odd numbers + possibly 1 for number 2)
    const capacity = (end - start) / 2 + 1;
    var range = std.ArrayList(u32).init(allocator);
    try range.resize(capacity); // resize to capacity

    // Special case for number 2
    if (start <= 2 and end > 2) {
        try range.append(2);
    }

    // Start from the first odd number >= start
    var current = start;
    if (current % 2 == 0) current += 1; // Make sure we start with an odd number

    // Add all odd numbers in range
    while (current < end) : (current += 2) {
        try range.append(current);
    }

    return range;
}

fn distributeWorkload(allocator: std.mem.Allocator, upper_limit: u32, thread_count: u32) !std.ArrayList(ThreadWorkload) {
    var workloads = std.ArrayList(ThreadWorkload).init(allocator);
    errdefer {
        for (workloads.items) |*workload| {
            workload.deinit();
        }
        workloads.deinit();
    }

    const base_chunk_size = upper_limit / thread_count;
    const remainder = upper_limit % thread_count;

    var start: u32 = 1;
    for (0..thread_count) |i| {
        const chunk_size = base_chunk_size + if (i < remainder) @as(u32, 1) else @as(u32, 0);
        const end = start + chunk_size;

        const numbers = try createNumberRange(allocator, start, end);
        try workloads.append(.{ .numbers = numbers });

        start = end;
    }

    return workloads;
}

// Prime finding parallel implementation
fn findPrimesParallel(allocator: std.mem.Allocator, upper_limit: u32, thread_count: u32) !std.ArrayList(u32) {
    // Initialize result array with estimated capacity
    const estimated_capacity = if (upper_limit <= 10_000_000) PRIMES_IN_10M else upper_limit / 10;
    var result = try std.ArrayList(u32).initCapacity(allocator, estimated_capacity);
    errdefer result.deinit();

    // If upper_limit is less than 2, we're done
    if (upper_limit < 2) return result;

    // Distribute work among threads
    var workloads = try distributeWorkload(allocator, upper_limit, thread_count);
    defer {
        for (workloads.items) |*workload| {
            workload.deinit();
        }
        workloads.deinit();
    }

    // Initialize thread pool
    const opt = Pool.Options{
        .n_jobs = @as(usize, thread_count),
        .allocator = allocator,
    };
    var pool: Pool = undefined;
    try pool.init(opt);
    defer pool.deinit();

    var result_mutex = Mutex{};
    var wait_group = std.Thread.WaitGroup{};

    // start timer
    timer = try std.time.Timer.start();

    // Process workloads in parallel
    for (workloads.items) |workload| {
        wait_group.start();
        try pool.spawn(struct {
            fn process(wg: *std.Thread.WaitGroup, numbers: []u32, primes: *std.ArrayList(u32), mutex: *Mutex) void {
                defer wg.finish();

                var local_primes = std.ArrayList(u32).init(std.heap.page_allocator);
                defer local_primes.deinit();

                for (numbers) |num| {
                    // No need to check even num since we only generate odd numbers (except 2)
                    if (isPrime(num)) {
                        local_primes.append(num) catch return;
                    }
                }

                if (local_primes.items.len > 0) {
                    mutex.lock();
                    defer mutex.unlock();
                    for (local_primes.items) |prime| {
                        primes.append(prime) catch {};
                    }
                }
            }
        }.process, .{ &wait_group, workload.numbers.items, &result, &result_mutex });
    }

    wait_group.wait();
    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try stdout.print("\nParallel Prime Number Finder using Trial Division\n", .{});

    while (true) {
        const upper_limit = try userNumberInput("Upper limit for prime search: ");
        const thread_count = try userNumberInput("Number of threads to use: ");

        // var timer = try std.time.Timer.start(); // start measuring time right after prep finished - not now

        var primes = try findPrimesParallel(allocator, upper_limit, thread_count);
        defer primes.deinit();

        const elapsed_seconds = @as(f64, @floatFromInt(timer.read())) / 1_000_000_000.0;
        try stdout.print("Found {d} primes in {d:.3} seconds\n", .{ primes.items.len, elapsed_seconds });

        if (try userResponseYN("Display results? (y/n): ")) {
            for (primes.items) |prime| {
                try stdout.print("{} ", .{prime});
            }
            try stdout.print("\n", .{});
        }

        if (!try userResponseYN("Another search? (y/n): ")) break;
    }
}

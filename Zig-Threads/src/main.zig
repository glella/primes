// to run prgm: zig build run
// to run the tests: zig build test
// zig build-exe primes.zig -O ReleaseFast or ReleaseSafe

const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
// const expect = std.testing.expect;

fn isPrime(n: u32) bool {
    switch (n) {
        0, 1 => return false,
        2 => return true,
        else => {
            if (n % 2 == 0) {
                return false;
            }
            var i: u32 = 3;
            while (i * i <= n) : (i += 2) {
                if (n % i == 0) {
                    return false;
                }
            }
        },
    }
    return true;
}

fn userInput(message: []const u8) !u32 {
    var buf: [10]u8 = undefined;
    try stdout.print("\n{s}", .{message});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return std.fmt.parseInt(u32, user_input, 10);
    } else {
        return @as(u32, 0);
    }
}

fn userAffirmative(message: []const u8) !bool {
    var buf: [10]u8 = undefined;
    try stdout.print("{s}", .{message});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |resp| {
        if (std.mem.eql(u8, "y", resp)) {
            return true;
        }
    } else {
        try stdout.print("Error: failed to parse response from console\n", .{});
    }
    return false;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try stdout.print("\nLooks for prime numbers from 1 to your input using trial division\n", .{});

    while (true) {
        const num: u32 = try userInput("Seek until what integer number?: ");
        var result = try std.ArrayList(u32).initCapacity(allocator, 664579); // 664,579 primes in 10M

        // Create an array of numbers to be iterated upon and evaluated  
        const oddCount = (num - 3 + 2) / 2; // Calculate the number of odd numbers in the range
        var arr: []u32 = try allocator.alloc(u32, oddCount); // Allocate an array of the appropriate size      
        // Fill the array with odd numbers
        var idx: usize = 0;
        var j: u32 = 3;
        while (j < num) : (j += 2) {
            arr[idx] = j;
            idx += 1;
        }
        // try stdout.print("Array: {any}\n", .{arr}); // Print the array

        // const thread_num: u32 = try userInput("Number of Threads to use?: ");
        // var threads: [thread_num]std.Thread = undefined;
        // var locks: [thread_num]std.Mutex = undefined;
        var threads: [4]std.Thread = undefined;
        var locks: [4]std.Thread.Mutex = undefined;
        _ = threads;
        _ = locks;

        // start the clock
        var timer: std.time.Timer = try std.time.Timer.start();
        
        try result.append(2); // add 2 manually as we start checking at 3

        // // for (locks, threads) |mut lock, mut thread| {
        // //     lock = try std.Thread.Mutex.init;
        // //     thread = try std.Thread.spawn(.{}, {
        // //         lock.lock();
        // //         for (arr) |i| {
        // //             if (isPrime(i)) {
        // //                 try result.append(i);
        // //             } 
        // //         }
        // //         lock.unlock();
        // //     });
            
        // // }

        // // for (threads) |mut thread| {
        // //     thread.join(). catch |err| {
        // //         std.log.err("{s}\n", .{err});
        // //     }
        // // }

        // for (arr) |i| {
        //    if (isPrime(i)) {
        //         try result.append(i);
        //     } 
        // }

        // stop the clock
        const elapsed: f64 = @intToFloat(f64, timer.read()) / 1_000_000_000.0;
        try stdout.print("Found: {} primes.\n", .{result.items.len});
        try stdout.print("Took: {d:.3} secs.\n", .{elapsed});

        if (try userAffirmative("Print them? (y/n): ")) {
            for (result.items) |item| {
                try stdout.print("{} ", .{item});
            }
            try stdout.print("\n", .{});
        }

        if (!try userAffirmative("Another run? (y/n): ")) {
            break;
        }
    }
}

test " for capture" {
    // Create two arrays of different lengths
    const a = [4]u8{ 1, 2, 3, 4 };
    const b = [4]u8{ 5, 6, 7, 8 };

    // Iterate over both arrays simultaneously
    for (a, b) |x, y| {
    std.debug.print("x = {}, y = {}\n", .{ x, y });
    }
}

fn thunk(num_threads: usize, thread_id: usize) void {
    std.debug.print("{}/{}\n", .{ thread_id, num_threads, });
}

test "threads test" {
    var child_threads: [7]std.Thread = undefined;

    for (child_threads, 0..) |thread, i| thread = try std.Thread.spawn(.{}, thunk, .{ 8, i + 1, });
    thunk(8, 0);

    for (child_threads) |thread| thread.join();
}
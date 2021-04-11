//zig build-exe primes.zig -O ReleaseSafe
const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

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
    const allocator = &arena.allocator;
    try stdout.print("\nLooks for prime numbers from 1 to your input using trial division\n", .{});

    while (true) {
        const num: u32 = try userInput("Seek until what integer number?: ");
        var result = try std.ArrayList(u32).initCapacity(allocator, 80000); // 78498 primes in 1M

        // start the clock
        const timer: std.time.Timer = try std.time.Timer.start();
        
        try result.append(2); // add 2 manually as we start checking at 3
        var i: u32 = 3;
        while (i < num) : (i += 2) {
            if (isPrime(i)) {
                try result.append(i);
            }
        }

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

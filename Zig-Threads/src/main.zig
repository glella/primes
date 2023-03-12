// to run prgm: zig build run
// to run the tests: zig build test
// zig build-exe primes.zig -O ReleaseFast or ReleaseSafe

const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

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
    _ = allocator;
}


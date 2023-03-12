// to run prgm: zig build run
// to run the tests: zig build test
// zig build-exe primes.zig -O ReleaseFast

const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

pub fn main() !void {}

// Assignment
// const constant: i32 = 5; // signed 32-bit constant
// var variable: u32 = 5000; // unsigned 32-bit variable

// @as performs an explicit type coercion
// const inferred_constant = @as(i32, 5);
// var inferred_variable = @as(u32, 5000);

// Arrays are denoted by [N]T, where N is the number of elements in the array and T is the type of those
// elements (i.e., the array’s child type).
// For array literals, N may be replaced by _ to infer the size of the array.

test "if statement" {
    const a = true;
    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    try expect(x == 1);
}

test "if statement expression" {
    const a = true;
    var x: u16 = 0;
    x += if (a) 1 else 2;
    try expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    try expect(i == 128);
}

test "while with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    try expect(sum == 55);
}

test "while with continue" {
    var sum: u8 = 0;
    var i: u8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) continue;
        sum += i;
    }
    try expect(sum == 4);
}

test "while with break" {
    var sum: u8 = 0;
    var i: u8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) break;
        sum += i;
    }
    try expect(sum == 1);
}

// Here we’ve had to assign values to _, as Zig does not allow us to have unused values

test "for" {
    //character literals are equivalent to integer literals
    const string = [_]u8{ 'a', 'b', 'c' };

    for (string, 0..) |character, index| {
        _ = character;
        _ = index;
    }

    for (string) |character| {
        _ = character;
    }

    for (string, 0..) |_, index| {
        _ = index;
    }

    for (string) |_| {}
}

// Unlike variables which are snake_case, functions are camelCase

fn addFive(x: u32) u32 {
    return x + 5;
}

test "function" {
    const y = addFive(0);
    try expect(@TypeOf(y) == u32);
    try expect(y == 5);
}

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "function recursion" {
    const x = fibonacci(10);
    try expect(x == 55);
}

// Defer is used to execute a statement while exiting the current block.

test "defer" {
    var x: i16 = 5;
    {
        defer x += 2;
        try expect(x == 5);
    }
    try expect(x == 7);
}

// When there are multiple defers in a single block, they are executed in reverse order.

test "multi defer" {
    var x: f32 = 5;
    {
        defer x += 2;
        defer x /= 2;
    }
    try expect(x == 4.5);
}

// An error set is like an enum (details on Zig’s enums later), where each error in the set is a value.
// There are no exceptions in Zig; errors are values. Let’s create an error set.

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

// Error sets coerce to their supersets.
const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a superset" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expect(err == FileOpenError.OutOfMemory);
}

// An error set type and a normal type can be combined with the ! operator to form an error union type.
// Values of these types may be an error value, or a value of the normal type.

// Let’s create a value of an error union type. Here catch is used, which is followed by an expression which
// is evaluated when the value before it is an error. The catch here is used to provide a fallback value,
// but could instead be a noreturn - the type of return, while (true) and others.

test "error union" {
    const maybe_error: AllocationError!u16 = 10;
    const no_error = maybe_error catch 0;

    try expect(@TypeOf(no_error) == u16);
    try expect(no_error == 10);
}

// Functions often return error unions. Here’s one using a catch, where the |err| syntax receives the value
// of the error. This is called payload capturing, and is used similarly in many places.

fn failingFunction() error{Oops}!void {
    return error.Oops;
}

test "returning an error" {
    failingFunction() catch |err| {
        try expect(err == error.Oops);
        return;
    };
}

// try x is a shortcut for x catch |err| return err, and is commonly used in places where handling an error
// isn’t appropriate. Zig’s try and catch are unrelated to try-catch in other languages.

fn failFn() error{Oops}!i32 {
    try failingFunction();
    return 12;
}

test "try" {
    var v = failFn() catch |err| {
        try expect(err == error.Oops);
        return;
    };
    try expect(v == 12); // is never reached
}

// errdefer works like defer, but only executing when the function is returned from with an error inside
// of the errdefer’s block.

var problems: u32 = 98;

fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFunction();
}

test "errdefer" {
    failFnCounter() catch |err| {
        try expect(err == error.Oops);
        try expect(problems == 99);
        return;
    };
}

// Error unions returned from a function can have their error sets inferred by not having an explicit
// error set. This inferred error set contains all possible errors which the function may return.

fn createFile() !void {
    return error.AccessDenied;
}

test "inferred error set" {
    //type coercion successfully takes place
    const x: error{AccessDenied}!void = createFile();

    //Zig does not let us ignore error unions via _ = x;
    //we must unwrap it with "try", "catch", or "if" by any means
    _ = x catch {};
}

// Error sets can be merged.

// const A = error{ NotDir, PathNotFound };
// const B = error{ OutOfMemory, PathNotFound };
// const C = A || B;

// anyerror is the global error set which due to being the superset of all error sets, can have an error
//  from any set coerce to a value of it. Its usage should be generally avoided.

// Zig’s switch works as both a statement and an expression. The types of all branches must coerce to the
// type which is being switched upon. All possible values must have an associated branch - values cannot be
// left out. Cases cannot fall through to other branches.

// The else is required to satisfy the exhaustiveness of this switch.

test "switch statement" {
    var x: i8 = 10;
    switch (x) {
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            //special considerations must be made
            //when dividing signed integers
            x = @divExact(x, 10);
        },
        else => {},
    }
    try expect(x == 1);
}

test "switch expression" {
    var x: i8 = 10;
    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    try expect(x == 1);
}

// Runtime Safety
// Users are strongly recommended to develop and test their software with safety on, despite its speed penalties.
// Safety is off for some build modes
// The user may choose to disable runtime safety for the current block by using the built-in function @setRuntimeSafety.

test "out of bounds, no safety" {
    @setRuntimeSafety(false);
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    const b = a[index];
    _ = b;
}

// unreachable is an assertion to the compiler that this statement will not be reached. It can be used to tell
// the compiler that a branch is impossible, which the optimiser can then take advantage of. Reaching an unreachable
// is detectable illegal behaviour.

// As it is of the type noreturn, it is compatible with all other types. Here it coerces to u32.

test "unreachable" {
    const x: i32 = 1;
    const y: u32 = if (x == 1) 5 else unreachable; // try changing to x == 2
    _ = y;
}

// Here is an unreachable being used in a switch.

fn asciiToUpper(x: u8) u8 {
    return switch (x) {
        'a'...'z' => x + 'A' - 'a',
        'A'...'Z' => x,
        else => unreachable,
    };
}

test "unreachable switch" {
    try expect(asciiToUpper('a') == 'A');
    try expect(asciiToUpper('A') == 'A');
}

// Normal pointers in Zig aren’t allowed to have 0 or null as a value. They follow the syntax *T, where T is
// the child type.

// Referencing is done with &variable, and dereferencing is done with variable.*.

fn increment(num: *u8) void {
    num.* += 1;
}

test "pointers" {
    var x: u8 = 1;
    increment(&x);
    try expect(x == 2);
}

// Trying to set a *T to the value 0 is detectable illegal behaviour.

test "naughty pointer" {
    var x: u16 = 1; // try setting to zero
    var y: *u8 = @intToPtr(*u8, x);
    _ = y;
}

// Zig also has const pointers, which cannot be used to modify the referenced data. Referencing a const variable will yield a const pointer.

// test "const pointers" {
//     const x: u8 = 1;
//     var y = &x;
//     y.* += 1;
// }

// error: cannot assign to constant
//     y.* += 1;
//         ^

// A *T coerces to a *const T.

// Pointer sized integers
// usize and isize are given as unsigned and signed integers which are the same size as pointers.

test "usize" {
    try expect(@sizeOf(usize) == @sizeOf(*u8));
    try expect(@sizeOf(isize) == @sizeOf(*u8));
}

// Many-Item Pointers
// Sometimes you may have a pointer to an unknown amount of elements. [*]T is the solution for this, which
// works like *T but also supports indexing syntax, pointer arithmetic, and slicing. Unlike *T, it cannot point
// to a type which does not have a known size. *T coerces to [*]T.

// These many pointers may point to any amount of elements, including 0 and 1.

// Slices
// Slices can be thought of as a pair of [*]T (the pointer to the data) and a usize (the element count).
// Their syntax is given as []T, with T being the child type.
// Slices have the same attributes as pointers, meaning that there also exists const slices.
// For loops also operate over slices. String literals in Zig coerce to []const u8.

fn total(values: []const u8) usize {
    var sum: usize = 0;
    for (values) |v| sum += v;
    return sum;
}
test "slices" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(total(slice) == 6);
}

// When these n and m values are both known at compile time, slicing will actually produce a pointer to an array.
// This is not an issue as a pointer to an array i.e. *[N]T will coerce to a []T.

test "slices 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(@TypeOf(slice) == *const [3]u8);
}

// The syntax x[n..] can also be used for when you want to slice to the end.

test "slices 3" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    var slice = array[0..];
    _ = slice;
}

// Types that may be sliced are: arrays, many pointers and slices.

// Enums
// Zig’s enums allow you to define types which have a restricted set of named values.
// const Direction = enum { north, south, east, west };

// Enums types may have specified (integer) tag types.

const Value = enum(u2) { zero, one, two };

// Enum’s ordinal values start at 0. They can be accessed with the built-in function @enumToInt.

test "enum ordinal value" {
    try expect(@enumToInt(Value.zero) == 0);
    try expect(@enumToInt(Value.one) == 1);
    try expect(@enumToInt(Value.two) == 2);
}

// Values can be overridden, with the next values continuing from there.

const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
    next,
};

test "set enum ordinal value" {
    try expect(@enumToInt(Value2.hundred) == 100);
    try expect(@enumToInt(Value2.thousand) == 1000);
    try expect(@enumToInt(Value2.million) == 1000000);
    try expect(@enumToInt(Value2.next) == 1000001);
}

// Methods can be given to enums. These act as namespaced functions that can be called with dot syntax.

const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

test "enum method" {
    try expect(Suit.spades.isClubs() == Suit.isClubs(.spades));
}

// Enums can also be given var and const declarations. These act as namespaced globals, and their values are unrelated and unattached to instances of the enum type.

const Mode = enum {
    var count: u32 = 0;
    on,
    off,
};

test "hmm" {
    Mode.count += 1;
    try expect(Mode.count == 1);
}

// Structs
// Structs are Zig’s most common kind of composite data type, allowing you to define types that can store a fixed
// set of named fields. Zig gives no guarantees about the in-memory order of fields in a struct, or its size.

const Vec3 = struct { x: f32, y: f32, z: f32 };

test "struct usage" {
    const my_vector = Vec3{
        .x = 0,
        .y = 100,
        .z = 50,
    };
    _ = my_vector;
}

// All fields must be given a value.

// Fields may be given defaults:

const Vec4 = struct { x: f32, y: f32, z: f32 = 0, w: f32 = undefined };

test "struct defaults" {
    const my_vector = Vec4{
        .x = 25,
        .y = -50,
    };
    _ = my_vector;
}

// Like enums, structs may also contain functions and declarations.

// Structs have the unique property that when given a pointer to a struct, one level of dereferencing is done
// automatically when accessing fields. Notice how in this example, self.x and self.y are accessed in the swap
// function without needing to dereference the self pointer.

const Stuff = struct {
    x: i32,
    y: i32,
    fn swap(self: *Stuff) void {
        const tmp = self.x;
        self.x = self.y;
        self.y = tmp;
    }
};

test "automatic dereference" {
    var thing = Stuff{ .x = 10, .y = 20 };
    thing.swap();
    try expect(thing.x == 20);
    try expect(thing.y == 10);
}

// Unions
// Zig’s unions allow you to define types which store one value of many possible typed fields; only one field may be
// active at one time.

// Bare union types do not have a guaranteed memory layout. Because of this, bare unions cannot be used to reinterpret
//  memory. Accessing a field in a union which is not active is detectable illegal behaviour.

const Result = union {
    int: i64,
    float: f64,
    bool: bool,
};

test "simple union" {
    var result = Result{ .int = 1234 };
    result.int = 4321; // try result.float = 12.34;
}

// Tagged unions are unions which use an enum to detect which field is active. Here we make use of payload capturing
// again, to switch on the tag type of a union while also capturing the value it contains. Here we use a pointer
// capture; captured values are immutable, but with the |*value| syntax we can capture a pointer to the values instead
// of the values themselves. This allows us to use dereferencing to mutate the original value.

const Tag = enum { a, b, c };

const Tagged = union(Tag) { a: u8, b: f32, c: bool };

test "switch on tagged union" {
    var value = Tagged{ .b = 1.5 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*b| b.* = !b.*,
    }
    try expect(value.b == 3);
}

// The tag type of a tagged union can also be inferred. This is equivalent to the Tagged type above.

// const Tagged = union(enum) { a: u8, b: f32, c: bool };

// void member types can have their type omitted from the syntax. Here, none is of type void.

const Tagged2 = union(enum) { a: u8, b: f32, c: bool, none };

// Integer Rules
// Zig supports hex, octal and binary integer literals.

// const decimal_int: i32 = 98222;
// const hex_int: u8 = 0xff;
// const another_hex_int: u8 = 0xFF;
// const octal_int: u16 = 0o755;
// const binary_int: u8 = 0b11110000;

// Underscores may also be placed between digits as a visual separator.

// const one_billion: u64 = 1_000_000_000;
// const binary_mask: u64 = 0b1_1111_1111;
// const permissions: u64 = 0o7_5_5;
// const big_address: u64 = 0xFF80_0000_0000_0000;

// "Integer Widening” is allowed, which means that integers of a type may coerce to an integer of another type,
// providing that the new type can fit all of the values that the old type can.

test "integer widening" {
    const a: u8 = 250;
    const b: u16 = a;
    const c: u32 = b;
    try expect(c == a);
}

// If you have a value stored in an integer that cannot coerce to the type that you want, @intCast may be used to
// explicitly convert from one type to the other. If the value given is out of the range of the destination type,
// this is detectable illegal behaviour.

test "@intCast" {
    const x: u64 = 200; // try with 300
    const y = @intCast(u8, x);
    try expect(@TypeOf(y) == u8);
}

// Integers by default are not allowed to overflow. Overflows are detectable illegal behaviour. Sometimes being able
// to overflow integers in a well defined manner is wanted behaviour. For this use case, Zig provides overflow operators.
// Normal Operator	Wrapping Operator
//      +	            +%
//      -	            -%
//      *	            *%
//      +=	            +%=
//      -=	            -%=
//      *=	            *%=

test "well defined overflow" {
    var a: u8 = 255;
    a +%= 1;
    try expect(a == 0);
}

// Floats
// Zig’s floats are strictly IEEE compliant unless @setFloatMode(.Optimized) is used, which is equivalent to
// GCC’s -ffast-math. Floats coerce to larger float types.

test "float widening" {
    const a: f16 = 0;
    const b: f32 = a;
    const c: f128 = b;
    try expect(c == @as(f128, a));
}

// Floats support multiple kinds of literal.

// const floating_point: f64 = 123.0E+77;
// const another_float: f64 = 123.0;
// const yet_another: f64 = 123.0e+77;

// const hex_floating_point: f64 = 0x103.70p-5;
// const another_hex_float: f64 = 0x103.70;
// const yet_another_hex_float: f64 = 0x103.70P-5;

// Underscores may also be placed between digits.

// const lightspeed: f64 = 299_792_458.000_000;
// const nanosecond: f64 = 0.000_000_001;
// const more_hex: f64 = 0x1234_5678.9ABC_CDEFp-10;

// Integers and floats may be converted using the built-in functions @intToFloat and @floatToInt.
// @intToFloat is always safe, whereas @floatToInt is detectable illegal behaviour if the float value cannot
// fit in the integer destination type.

test "int-float conversion" {
    const a: i32 = 0;
    const b = @intToFloat(f32, a);
    const c = @floatToInt(i32, b);
    try expect(c == a);
}

// Labelled Blocks
// Blocks in Zig are expressions and can be given labels, which are used to yield values. Here, we are using a label
// called blk. Blocks yield values, meaning that they can be used in place of a value. The value of an empty block {}
// is a value of the type void.

test "labelled blocks" {
    const count = blk: {
        var sum: u32 = 0;
        var i: u32 = 0;
        while (i < 10) : (i += 1) sum += i;
        break :blk sum;
    };
    try expect(count == 45);
    try expect(@TypeOf(count) == u32);
}

// This can be seen as being equivalent to C’s i++.

// blk: {
//     const tmp = i;
//     i += 1;
//     break :blk tmp;
// }

// Labelled Loops
// Loops can be given labels, allowing you to break and continue to outer loops.

test "nested continue" {
    var count: usize = 0;
    outer: for ([_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }) |_| {
        for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
            count += 1;
            continue :outer;
        }
    }
    try expect(count == 8);
}

// Loops as expressions
// Like return, break accepts a value. This can be used to yield a value from a loop. Loops in Zig also have an
// else branch on loops, which is evaluated when the loop is not exited from with a break.

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

test "while loop expression" {
    try expect(rangeHasNumber(0, 10, 3)); // try with 11
}

// Optionals
// Optionals use the syntax ?T and are used to store the data null, or a value of type T.

test "optional" {
    var found_index: ?usize = null;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 12 };
    for (data, 0..) |v, i| {
        if (v == 10) found_index = i;
    }
    try expect(found_index == null);
}

// Optionals support the orelse expression, which acts when the optional is null.
// This unwraps the optional to its child type.

test "orelse" {
    var a: ?f32 = null;
    var b = a orelse 0;
    try expect(b == 0);
    try expect(@TypeOf(b) == f32);
}

// .? is a shorthand for orelse unreachable. This is used for when you know it is impossible for an optional
// value to be null, and using this to unwrap a null value is detectable illegal behaviour.

test "orelse unreachable" {
    const a: ?f32 = 5;
    const b = a orelse unreachable;
    const c = a.?;
    try expect(b == c);
    try expect(@TypeOf(c) == f32);
}

// Payload capturing works in many places for optionals, meaning that in the event that it is non-null we can
// “capture” its non-null value.

// Here we use an if optional payload capture; a and b are equivalent here. if (b) |value| captures the value of
// b (in the cases where b is not null), and makes it available as value. As in the union example, the captured value
// is immutable, but we can still use a pointer capture to modify the value stored in b.

test "if optional payload capture" {
    const a: ?i32 = 5;
    if (a != null) {
        const value = a.?;
        _ = value;
    }

    var b: ?i32 = 5;
    if (b) |*value| {
        value.* += 1;
    }
    try expect(b.? == 6);
}

// And with while:

var numbers_left: u32 = 4;
fn eventuallyNullSequence() ?u32 {
    if (numbers_left == 0) return null;
    numbers_left -= 1;
    return numbers_left;
}

test "while null capture" {
    var sum: u32 = 0;
    while (eventuallyNullSequence()) |value| {
        sum += value;
    }
    try expect(sum == 6); // 3 + 2 + 1
}

// Optional pointer and optional slice types do not take up any extra memory, compared to non-optional ones.
// This is because internally they use the 0 value of the pointer for null.

// This is how null pointers in Zig work - they must be unwrapped to a non-optional before dereferencing,
// which stops null pointer dereferences from happening accidentally.

// Comptime
// Blocks of code may be forcibly executed at compile time using the comptime keyword. In this example,
// the variables x and y are equivalent.

test "comptime blocks" {
    var x = comptime fibonacci(10);
    // _ = x;

    var y = comptime blk: {
        break :blk fibonacci(10);
    };
    // _ = y;

    try expect(x == y);
}

// Integer literals are of the type comptime_int. These are special in that they have no size (they cannot be
// used at runtime!), and they have arbitrary precision. comptime_int values coerce to any integer type that can
// hold them. They also coerce to floats. Character literals are of this type.

test "comptime_int" {
    const a = 12;
    const b = a + 10;

    const c: u4 = a;
    _ = c;
    const d: f32 = b;
    _ = d;
}

// comptime_float is also available, which internally is an f128. These cannot be coerced to integers, even if they
// hold an integer value.

// Types in Zig are values of the type type. These are available at compile time. We have previously encountered them
// by checking @TypeOf and comparing with other types, but we can do more.

test "branching on types" {
    const a = 5;
    const b: if (a < 10) f32 else i32 = 5;
    _ = b;
}

// Function parameters in Zig can be tagged as being comptime. This means that the value passed to that function
// parameter must be known at compile time. Let’s make a function that returns a type. Notice how this function is
// PascalCase, as it returns a type.

fn Matrix(
    comptime T: type,
    comptime width: comptime_int,
    comptime height: comptime_int,
) type {
    return [height][width]T;
}

test "returning a type" {
    try expect(Matrix(f32, 4, 4) == [4][4]f32);
}

// We can reflect upon types using the built-in @typeInfo, which takes in a type and returns a tagged union.
// This tagged union type can be found in std.builtin.TypeInfo

fn addSmallInts(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16)
            a + b
        else
            @compileError("ints too large"),
        else => @compileError("only ints accepted"),
    };
}

test "typeinfo switch" {
    const x = addSmallInts(u16, 20, 30);
    try expect(@TypeOf(x) == u16);
    try expect(x == 50);
}

// We can use the @Type function to create a type from a @typeInfo. @Type is implemented for most types but is
// notably unimplemented for enums, unions, functions, and structs.

// Here anonymous struct syntax is used with .{}, because the T in T{} can be inferred. Anonymous structs will be
// covered in detail later. In this example we will get a compile error if the Int tag isn’t set.

fn GetBiggerInt(comptime T: type) type {
    return @Type(.{
        .Int = .{
            .bits = @typeInfo(T).Int.bits + 1,
            .signedness = @typeInfo(T).Int.signedness,
        },
    });
}

test "@Type" {
    try expect(GetBiggerInt(u8) == u9);
    try expect(GetBiggerInt(i31) == i32);
}

// Returning a struct type is how you make generic data structures in Zig. The usage of @This is required here,
// which gets the type of the innermost struct, union, or enum. Here std.mem.eql is also used which compares two slices.

fn Vec(
    comptime count: comptime_int,
    comptime T: type,
) type {
    return struct {
        data: [count]T,
        const Self = @This();

        fn abs(self: Self) Self {
            var tmp = Self{ .data = undefined };
            for (self.data, 0..) |elem, i| {
                tmp.data[i] = if (elem < 0)
                    -elem
                else
                    elem;
            }
            return tmp;
        }

        fn init(data: [count]T) Self {
            return Self{ .data = data };
        }
    };
}

const eql = @import("std").mem.eql;

test "generic vector" {
    const x = Vec(3, f32).init([_]f32{ 10, -10, 5 });
    const y = x.abs();
    try expect(eql(f32, &y.data, &[_]f32{ 10, 10, 5 }));
}

// The types of function parameters can also be inferred by using anytype in place of a type. @TypeOf can then be
// used on the parameter.

fn plusOne(x: anytype) @TypeOf(x) {
    return x + 1;
}

test "inferred function parameter" {
    try expect(plusOne(@as(u32, 1)) == 2);
}

// Comptime also introduces the operators ++ and ** for concatenating and repeating arrays and slices.
// These operators do not work at runtime.

test "++" {
    const x: [4]u8 = undefined;
    const y = x[0..];

    const a: [6]u8 = undefined;
    const b = a[0..];

    const new = y ++ b;
    try expect(new.len == 10);
}

test "**" {
    const pattern = [_]u8{ 0xCC, 0xAA };
    const memory = pattern ** 3;
    try expect(eql(u8, &memory, &[_]u8{ 0xCC, 0xAA, 0xCC, 0xAA, 0xCC, 0xAA }));
}

// Payload Captures
// Payload captures use the syntax |value| and appear in many places, some of which we’ve seen already. Wherever
// they appear, they are used to “capture” the value from something.

// With if statements and optionals.

test "optional-if" {
    var maybe_num: ?usize = 10;
    if (maybe_num) |n| {
        try expect(@TypeOf(n) == usize);
        try expect(n == 10);
    } else {
        unreachable;
    }
}

// With if statements and error unions. The else with the error capture is required here.

test "error union if" {
    var ent_num: error{UnknownEntity}!u32 = 5;
    if (ent_num) |entity| {
        try expect(@TypeOf(entity) == u32);
        try expect(entity == 5);
    } else |err| {
        _ = err catch {};
        unreachable;
    }
}

// With while loops and optionals. This may have an else block.

test "while optional" {
    var i: ?u32 = 10;
    while (i) |num| : (i.? -= 1) {
        try expect(@TypeOf(num) == u32);
        if (num == 1) {
            i = null;
            break;
        }
    }
    try expect(i == null);
}

// With while loops and error unions. The else with the error capture is required here.

var numbers_left2: u32 = undefined;

fn eventuallyErrorSequence() !u32 {
    return if (numbers_left2 == 0) error.ReachedZero else blk: {
        numbers_left2 -= 1;
        break :blk numbers_left2;
    };
}

test "while error union capture" {
    var sum: u32 = 0;
    numbers_left2 = 3;
    while (eventuallyErrorSequence()) |value| {
        sum += value;
    } else |err| {
        try expect(err == error.ReachedZero);
    }
}

// For loops

test "for capture" {
    const x = [_]i8{ 1, 5, 120, -5 };
    for (x) |v| try expect(@TypeOf(v) == i8);
}

// Switch cases on tagged unions

const Info = union(enum) {
    a: u32,
    b: []const u8,
    c,
    d: u32,
};

test "switch capture" {
    var b = Info{ .a = 10 };
    const x = switch (b) {
        .b => |str| blk: {
            try expect(@TypeOf(str) == []const u8);
            break :blk 1;
        },
        .c => 2,
        //if these are of the same type, they
        //may be inside the same capture group
        .a, .d => |num| blk: {
            try expect(@TypeOf(num) == u32);
            break :blk num * 2;
        },
    };
    try expect(x == 20);
}

// As we saw in the Union and Optional sections above, values captured with the |val| syntax are immutable
// (similar to function arguments), but we can use pointer capture to modify the original values. This captures
// the values as pointers that are themselves still immutable, but because the value is now a pointer, we can modify
// the original value by dereferencing it:

// Not anymore: error: pointer capture of non pointer type '[3]u8'
// test "for with pointer capture" {
//     var data = [_]u8{ 1, 2, 3 };
//     for (data) |*byte| byte.* += 1;
//     try expect(eql(u8, &data, &[_]u8{ 2, 3, 4 }));
// }

// Inline Loops
// inline loops are unrolled, and allow some things to happen which only work at compile time. Here we use a for,
// but a while works similarly.

test "inline for" {
    const types = [_]type{ i32, f32, u8, bool };
    var sum: usize = 0;
    inline for (types) |T| sum += @sizeOf(T);
    try expect(sum == 10);
}

// Using these for performance reasons is inadvisable unless you’ve tested that explicitly unrolling is faster;
// the compiler tends to make better decisions here than you.

// Opaque
// opaque types in Zig have an unknown (albeit non-zero) size and alignment. Because of this these data types
// cannot be stored directly. These are used to maintain type safety with pointers to types that we don’t have
// information about.

// const Window = opaque {};
// const Button = opaque {};

// extern fn show_window(*Window) callconv(.C) void;

// test "opaque" {
//     var main_window: *Window = undefined;
//     show_window(main_window);

//     var ok_button: *Button = undefined;
//     show_window(ok_button);
// }

// Opaque types may have declarations in their definitions (the same as structs, enums and unions).

// const Window = opaque {
//     fn show(self: *Window) void {
//         show_window(self);
//     }
// };

// extern fn show_window(*Window) callconv(.C) void;

// test "opaque with declarations" {
//     var main_window: *Window = undefined;
//     main_window.show();
// }

// The typical usecase of opaque is to maintain type safety when interoperating with C code that does not expose
// complete type information.

// Anonymous Structs
// The struct type may be omitted from a struct literal. These literals may coerce to other struct types.

test "anonymous struct literal" {
    const Point = struct { x: i32, y: i32 };

    var pt: Point = .{
        .x = 13,
        .y = 67,
    };
    try expect(pt.x == 13);
    try expect(pt.y == 67);
}

// Anonymous structs may be completely anonymous i.e. without being coerced to another struct type.

test "fully anonymous struct" {
    try dump(.{
        .int = @as(u32, 1234),
        .float = @as(f64, 12.34),
        .b = true,
        .s = "hi",
    });
}

fn dump(args: anytype) !void {
    try expect(args.int == 1234);
    try expect(args.float == 12.34);
    try expect(args.b);
    try expect(args.s[0] == 'h');
    try expect(args.s[1] == 'i');
}

// Anonymous structs without field names may be created, and are referred to as tuples. These have many of the
// properties that arrays do; tuples can be iterated over, indexed, can be used with the ++ and ** operators, and
// have a len field. Internally, these have numbered field names starting at "0", which may be accessed with the
// special syntax @"0" which acts as an escape for the syntax - things inside @"" are always recognised as identifiers

// An inline loop must be used to iterate over the tuple here, as the type of each tuple field may differ.

test "tuple" {
    const values = .{
        @as(u32, 1234),
        @as(f64, 12.34),
        true,
        "hi",
    } ++ .{false} ** 2;
    try expect(values[0] == 1234);
    try expect(values[4] == false);
    inline for (values, 0..) |v, i| {
        if (i != 2) continue;
        try expect(v);
    }
    try expect(values.len == 6);
    try expect(values.@"3"[0] == 'h');
}

// Sentinel Termination
// Arrays, slices and many pointers may be terminated by a value of their child type. This is known as sentinel
// termination. These follow the syntax [N:t]T, [:t]T, and [*:t]T, where t is a value of the child type T.

// An example of a sentinel terminated array. The built-in @bitCast is used to perform an unsafe bitwise type
// conversion. This shows us that the last element of the array is followed by a 0 byte.

// test "sentinel termination" {
//     const terminated = [3:0]u8{ 3, 2, 1 };
//     try expect(terminated.len == 3);
//     try expect(@bitCast([4]u8, terminated)[3] == 0);
// }

// The types of string literals is *const [N:0]u8, where N is the length of the string. This allows string literals
// to coerce to sentinel terminated slices, and sentinel terminated many pointers. Note: string literals are UTF-8
// encoded.

test "string literal" {
    try expect(@TypeOf("hello") == *const [5:0]u8);
}

// [*:0]u8 and [*:0]const u8 perfectly model C’s strings.

test "C string" {
    const c_string: [*:0]const u8 = "hello";
    var array: [5]u8 = undefined;

    var i: usize = 0;
    while (c_string[i] != 0) : (i += 1) {
        array[i] = c_string[i];
    }
}

// Sentinel terminated types coerce to their non-sentinel-terminated counterparts.

test "coercion" {
    var a: [*:0]u8 = undefined;
    const b: [*]u8 = a;
    _ = b;

    var c: [5:0]u8 = undefined;
    const d: [5]u8 = c;
    _ = d;

    var e: [:10]f32 = undefined;
    const f = e;
    _ = f;
}

// Sentinel terminated slicing is provided which can be used to create a sentinel terminated slice with the
// syntax x[n..m:t], where t is the terminator value. Doing this is an assertion from the programmer that the memory
// is terminated where it should be - getting this wrong is detectable illegal behaviour.

test "sentinel terminated slicing" {
    var x = [_:0]u8{255} ** 3;
    const y = x[0..3 :0];
    _ = y;
}

// Vectors
// Zig provides vector types for SIMD. These are not to be conflated with vectors in a mathematical sense, or
// vectors like C++’s std::vector (for this, see “Arraylist” in chapter 2). Vectors may be created using the @Type
// built-in we used earlier, and std.meta.Vector provides a shorthand for this.

// Vectors can only have child types of booleans, integers, floats and pointers.

// Operations between vectors with the same child type and length can take place. These operations are performed
// on each of the values in the vector.std.meta.eql is used here to check for equality between two vectors
// (also useful for other types like structs).

const meta = @import("std").meta;
const Vector = meta.Vector;

test "vector add" {
    const x: Vector(4, f32) = .{ 1, -10, 20, -1 };
    const y: Vector(4, f32) = .{ 2, 10, 0, 1 };
    const z = x + y;
    try expect(meta.eql(z, Vector(4, f32){ 3, 0, 20, 0 }));
}

// Vectors are indexable.

test "vector indexing" {
    const x: Vector(4, u8) = .{ 255, 0, 255, 0 };
    try expect(x[0] == 255);
}

// The built-in function @splat may be used to construct a vector where all of the values are the same.
// Here we use it to multiply a vector by a scalar.

test "vector * scalar" {
    const x: Vector(3, f32) = .{ 12.5, 37.5, 2.5 };
    const y = x * @splat(3, @as(f32, 2));
    try expect(meta.eql(y, Vector(3, f32){ 25, 75, 5 }));
}

// Vectors do not have a len field like arrays, but may still be looped over. Here, std.mem.len is used as a
// shortcut for @typeInfo(@TypeOf(x)).Vector.len.

// const len = @import("std").mem.len;

// test "vector looping" {
//     const x = Vector(4, u8){ 255, 0, 255, 0 };
//     var sum = blk: {
//         var tmp: u10 = 0;
//         var i: u8 = 0;
//         while (i < len(x)) : (i += 1) tmp += x[i];
//         break :blk tmp;
//     };
//     try expect(sum == 510);
// }

// Vectors coerce to their respective arrays.

const arr: [4]f32 = @Vector(4, f32){ 1, 2, 3, 4 };

// It is worth noting that using explicit vectors may result in slower software if you do not make the right
// decisions - the compiler’s auto-vectorisation is fairly smart as-is.

// Imports
// The built-in function @import takes in a file, and gives you a struct type based on that file. All declarations
// labelled as pub (for public) will end up in this struct type, ready for use.

// @import("std") is a special case in the compiler, and gives you access to the standard library.
// Other @imports will take in a file path, or a package name

// Allocators
// The Zig standard library provides a pattern for allocating memory, which allows the programmer to choose exactly 
// how memory allocations are done within the standard library - no allocations happen behind your back in the 
// standard library.

// The most basic allocator is std.heap.page_allocator. Whenever this allocator makes an allocation it will ask your 
// OS for entire pages of memory; an allocation of a single byte will likely reserve multiple kibibytes. As asking the
// OS for memory requires a system call this is also extremely inefficient for speed.

// Here, we allocate 100 bytes as a []u8. Notice how defer is used in conjunction with a free - this is a common 
// pattern for memory management in Zig.

test "allocation" {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);
}

// The std.heap.FixedBufferAllocator is an allocator that allocates memory into a fixed buffer, and does not make any 
// heap allocations. This is useful when heap usage is not wanted, for example when writing a kernel. It may also be 
// considered for performance reasons. It will give you the error OutOfMemory if it has run out of bytes.

test "fixed buffer allocator" {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);
}

// std.heap.ArenaAllocator takes in a child allocator, and allows you to allocate many times and only free once. 
// Here, .deinit() is called on the arena which frees all memory. Using allocator.free in this example would be a 
// no-op (i.e. does nothing).

test "arena allocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    _ = try allocator.alloc(u8, 1);
    _ = try allocator.alloc(u8, 10);
    _ = try allocator.alloc(u8, 100);
}

// alloc and free are used for slices. For single items, consider using create and destroy.

test "allocator create/destroy" {
    const byte = try std.heap.page_allocator.create(u8);
    defer std.heap.page_allocator.destroy(byte);
    byte.* = 128;
}

// The Zig standard library also has a general purpose allocator. This is a safe allocator which can prevent 
// double-free, use-after-free and can detect leaks. Safety checks and thread safety can be turned off via its 
// configuration struct (left empty below). Zig’s GPA is designed for safety over performance, but may still be many 
// times faster than page_allocator.

test "GPA" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const leaked = gpa.deinit();
        if (leaked) expect(false) catch @panic("TEST FAIL"); //fail test; can't try in defer as defer is executed after we return
    }
    
    const bytes = try allocator.alloc(u8, 100);
    defer allocator.free(bytes);
}

// For high performance (but very few safety features!), std.heap.c_allocator may be considered. This however has the 
// disadvantage of requiring linking Libc, which can be done with -lc.

// Arraylist
// The std.ArrayList is commonly used throughout Zig, and serves as a buffer which can change in size. 
// std.ArrayList(T) is similar to C++’s std::vector<T> and Rust’s Vec<T>. The deinit() method frees all of the 
// ArrayList’s memory. The memory can be read from and written to via its slice field - .items.

// Here we will introduce the usage of the testing allocator. This is a special allocator that only works in tests, 
// and can detect memory leaks. In your code, use whatever allocator is appropriate.

// const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

test "arraylist" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();
    try list.append('H');
    try list.append('e');
    try list.append('l');
    try list.append('l');
    try list.append('o');
    try list.appendSlice(" World!");

    try expect(eql(u8, list.items, "Hello World!"));
}

// Filesystem
// Let’s create and open a file in our current working directory, write to it, and then read from it. Here we have to 
// use .seekTo in order to go back to the start of the file before reading what we have written.

test "createFile, write, seekTo, read" {
    const file = try std.fs.cwd().createFile(
        "junk_file.txt",
        .{ .read = true },
    );
    defer file.close();

    const bytes_written = try file.writeAll("Hello File!");
    _ = bytes_written;

    var buffer: [100]u8 = undefined;
    try file.seekTo(0);
    const bytes_read = try file.readAll(&buffer);

    try expect(eql(u8, buffer[0..bytes_read], "Hello File!"));
}

// The functions std.fs.openFileAbsolute and similar absolute functions exist, but we will not test them here.

// We can get various information about files by using .stat() on them. Stat also contains fields for .inode and 
// .mode, but they are not tested here as they rely on the current OS’ types.

test "file stat" {
    const file = try std.fs.cwd().createFile(
        "junk_file2.txt",
        .{ .read = true },
    );
    defer file.close();
    const stat = try file.stat();
    try expect(stat.size == 0);
    try expect(stat.kind == .File);
    try expect(stat.ctime <= std.time.nanoTimestamp());
    try expect(stat.mtime <= std.time.nanoTimestamp());
    try expect(stat.atime <= std.time.nanoTimestamp());
}

// We can make directories and iterate over their contents. Here we will use an iterator (discussed later). 
// This directory (and its contents) will be deleted after this test finishes.

test "make dir" {
    try std.fs.cwd().makeDir("test-tmp");
    const dir = try std.fs.cwd().openDir(
        "test-tmp",
        .{  }, //.{ .iterate = true }, // regular openDir cannot iterate any longer but can create files
    );
    defer {
        std.fs.cwd().deleteTree("test-tmp") catch unreachable;
    }

    _ = try dir.createFile("x", .{});
    _ = try dir.createFile("y", .{});
    _ = try dir.createFile("z", .{});

    // changed - openIterableDir cannot create file but is needed to iterate
    const dir2 = try std.fs.cwd().openIterableDir("test-tmp", .{});

    var file_count: usize = 0;
    var iter = dir2.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .File) file_count += 1;
    }

    try expect(file_count == 3);
}

// Readers and Writers
// std.io.Writer and std.io.Reader provide standard ways of making use of IO. 
// std.ArrayList(u8) has a writer method which gives us a writer. Let’s use it.

test "io writer usage" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();
    const bytes_written = try list.writer().write(
        "Hello World!",
    );
    try expect(bytes_written == 12);
    try expect(eql(u8, list.items, "Hello World!"));
}

// Here we will use a reader to copy the file’s contents into an allocated buffer. The second argument of
// readAllAlloc is the maximum size that it may allocate; if the file is larger than this, it will return 
// error.StreamTooLong.

test "io reader usage" {
    const message = "Hello File!";

    const file = try std.fs.cwd().createFile(
        "junk_file2.txt",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(message);
    try file.seekTo(0);

    const contents = try file.reader().readAllAlloc(
        test_allocator,
        message.len,
    );
    defer test_allocator.free(contents);

    try expect(eql(u8, contents, message));
}

// A common usecase for readers is to read until the next line (e.g. for user input). 
// Here we will do this with the std.io.getStdIn() file.

// fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
//     var line = (try reader.readUntilDelimiterOrEof(
//         buffer,
//         '\n',
//     )) orelse return null;
//     // trim annoying windows-only carriage return character
//     if (@import("builtin").os.tag == .windows) {
//         return std.mem.trimRight(u8, line, "\r");
//     } else {
//         return line;
//     }
// }

// test "read until next line" {
//     const stdout = std.io.getStdOut();
//     const stdin = std.io.getStdIn();

//     try stdout.writeAll(
//         \\ Enter your name:
//     );

//     var buffer: [100]u8 = undefined;
//     const input = (try nextLine(stdin.reader(), &buffer)).?;
//     try stdout.writer().print(
//         "Your name is: \"{s}\"\n",
//         .{input},
//     );
// }

// Formatting
// std.fmt provides ways to format data to and from strings.

// A basic example of creating a formatted string. The format string must be compile time known. 
// The d here denotes that we want a decimal number.

test "fmt" {
    const string = try std.fmt.allocPrint(
        test_allocator,
        "{d} + {d} = {d}",
        .{ 9, 10, 19 },
    );
    defer test_allocator.free(string);

    try expect(eql(u8, string, "9 + 10 = 19"));
}

// Writers conveniently have a print method, which works similarly.

test "print" {
    var list = std.ArrayList(u8).init(test_allocator);
    defer list.deinit();
    try list.writer().print(
        "{} + {} = {}",
        .{ 9, 10, 19 },
    );
    try expect(eql(u8, list.items, "9 + 10 = 19"));
}

// Take a moment to appreciate that you now know from top to bottom how printing hello world works. 
// std.debug.print works the same, except it writes to stderr and is protected by a mutex.

test "hello world" {
    const out_file = std.io.getStdOut();
    try out_file.writer().print(
        "Hello, {s}!\n",
        .{"World"},
    );
}

// We have used the {s} format specifier up until this point to print strings. Here we will use {any}, which gives 
// us the default formatting.

test "array printing" {
    const string = try std.fmt.allocPrint(
        test_allocator,
        "{any} + {any} = {any}",
        .{
            @as([]const u8, &[_]u8{ 1, 4 }),
            @as([]const u8, &[_]u8{ 2, 5 }),
            @as([]const u8, &[_]u8{ 3, 9 }),
        },
    );
    defer test_allocator.free(string);

    try expect(eql(
        u8,
        string,
        "{ 1, 4 } + { 2, 5 } = { 3, 9 }",
    ));
}

// Let’s create a type with custom formatting by giving it a format function. This function must be marked as pub so 
// that std.fmt can access it (more on packages later). You may notice the usage of {s} instead of {} - this is the 
// format specifier for strings (more on format specifiers later). This is used here as {} defaults to array printing 
// over string printing.

const Person = struct {
    name: []const u8,
    birth_year: i32,
    death_year: ?i32,
    pub fn format(
        self: Person,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("{s} ({}-", .{
            self.name, self.birth_year,
        });

        if (self.death_year) |year| {
            try writer.print("{}", .{year});
        }

        try writer.writeAll(")");
    }
};

test "custom fmt" {
    const john = Person{
        .name = "John Carmack",
        .birth_year = 1970,
        .death_year = null,
    };

    const john_string = try std.fmt.allocPrint(
        test_allocator,
        "{s}",
        .{john},
    );
    defer test_allocator.free(john_string);

    try expect(eql(
        u8,
        john_string,
        "John Carmack (1970-)",
    ));

    const claude = Person{
        .name = "Claude Shannon",
        .birth_year = 1916,
        .death_year = 2001,
    };

    const claude_string = try std.fmt.allocPrint(
        test_allocator,
        "{s}",
        .{claude},
    );
    defer test_allocator.free(claude_string);

    try expect(eql(
        u8,
        claude_string,
        "Claude Shannon (1916-2001)",
    ));
}

// JSON
// Let’s parse a json string into a struct type, using the streaming parser.

const Place = struct { lat: f32, long: f32 };

test "json parse" {
    var stream = std.json.TokenStream.init(
        \\{ "lat": 40.684540, "long": -74.401422 }
    );
    const x = try std.json.parse(Place, &stream, .{});

    try expect(x.lat == 40.684540);
    try expect(x.long == -74.401422);
}

// And using stringify to turn arbitrary data into a string.

test "json stringify" {
    const x = Place{
        .lat = 51.997664,
        .long = -0.740687,
    };

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());
    try std.json.stringify(x, .{}, string.writer());

    try expect(eql(
        u8,
        string.items,
        \\{"lat":5.19976654e+01,"long":-7.40687012e-01}
    ));
}

// The json parser requires an allocator for javascript’s string, array, and map types. This memory may be freed 
// using std.json.parseFree.

test "json parse with strings" {
    var stream = std.json.TokenStream.init(
        \\{ "name": "Joe", "age": 25 }
    );

    const User = struct { name: []u8, age: u16 };

    const x = try std.json.parse(
        User,
        &stream,
        .{ .allocator = test_allocator },
    );

    defer std.json.parseFree(
        User,
        x,
        .{ .allocator = test_allocator },
    );

    try expect(eql(u8, x.name, "Joe"));
    try expect(x.age == 25);
}

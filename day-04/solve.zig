const std = @import("std");
const mem = std.mem;
const print = std.debug.print;

pub fn main() !void {
    const input = @embedFile("example");
    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        print("Line: {s}\n", .{line});
    }
}

const std = @import("std");

pub fn main() !void {
    // Print the greeting message to stdout
    std.debug.print("{s} {s}\n", .{ "Hello", "world" });
}

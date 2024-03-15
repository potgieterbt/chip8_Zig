const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var x: u32 = 1234;
    x = x + 1;
}

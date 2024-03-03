const std = @import("std");
const cpu = @import("cpu.zig");
const fs = std.fs;
const prs = std.process;

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const x = try readFile(allocator);
    defer allocator.free(x);
    var args = prs.args();
    while (args.next()) |i| {
        std.debug.print("{s}", .{i});
    }
}

fn readFile(allocator: std.mem.Allocator) ![](u8) {
    const file = try fs.cwd().openFile("./src/test.ch8", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const file_buffer = try allocator.alloc(u8, file_size);

    const n = try file.readAll(file_buffer);
    _ = n;

    return file_buffer;
}

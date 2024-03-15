const std = @import("std");
const cpu = @import("cpu.zig");
const fs = std.fs;

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_path = try parseArgumentsToFilePath();

    const rom = try cpu.cpu.loadRom(allocator, file_path);
    defer allocator.free(rom);

    for (rom) |i| {
        std.debug.print("{X}", .{i});
    }
}

fn parseArgumentsToFilePath() ![]const u8 {
    var args = std.process.args();
    // skip first argument
    const exe = args.next().?;
    _ = exe;

    return args.next() orelse return error.MissingArgument;
}

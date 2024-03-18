const std = @import("std");
const cpuimp = @import("cpu.zig");
const fs = std.fs;

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    const cpu = cpuimp.cpu;
    const allocator = std.heap.page_allocator;
    const file_path = try parseArgumentsToFilePath();

    const rom = try cpu.loadRom(allocator, file_path);
    defer allocator.free(rom);

    cpu.tick();
}

fn parseArgumentsToFilePath() ![]const u8 {
    var args = std.process.args();
    // skip first argument
    const exe = args.next().?;
    _ = exe;

    return args.next() orelse return error.MissingArgument;
}

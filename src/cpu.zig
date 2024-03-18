const std = @import("std");

const fontset = [80]u8{
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80, // F
};

pub const cpu = struct {
    const Self = @This();

    const mem_start: u16 = 0x200;
    var memory: [4096]u8 = [_]u8{0} ** 4096;
    var pc: u16 = 0;
    sp: u8,
    index_register: u16,
    registers: [16]u8,
    delay_timer: u8,
    sound_timer: u8,
    stack: [16]u16,

    pub fn loadRom(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const file_size = try file.getEndPos();

        const file_buffer = try allocator.alloc(u8, file_size);

        const n = try file.readAll(file_buffer);

        for (file_buffer, 0..n) |op, i| {
            cpu.memory[mem_start + i - 1] = op;
        }

        return file_buffer;
    }

    pub fn fetch() u16 {
        return @shlExact(@intCast(u16, memory[Self.pc]), 8) | memory[Self.pc + 1];
    }
    pub fn execture() void {}
    pub fn tick() void {
        const op = fetch();
        std.debug.print("{}", .{op});
    }
    pub fn debug() void {}

    fn decode() void {}
    fn disassemble() void {}
};

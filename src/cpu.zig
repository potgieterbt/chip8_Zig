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
    var pc: u16 = mem_start;
    var sp: u8 = 0;
    var index_register: u16 = 0;
    var registers: [16]u8 = [_]u8{0} ** 16;
    var delay_timer: u8 = 0;
    var sound_timer: u8 = 0;
    var stack: [16]u16 = [_]u16{0} ** 16;
    var clear_screen: bool = false;
    var is_debug: bool = true;

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
        const val: u16 = (@as(u16, memory[Self.pc]) << 8) | memory[Self.pc + 1];
        Self.pc += 2;
        return val;
    }

    pub fn execute(opcode: u16) !void {
        // std.debug.print("{X}\n", .{opcode});
        switch (opcode & 0xF000) {
            0x0000 => {
                switch (opcode & 0xF) {
                    0x0 => {
                        Self.clear_screen = true;
                    },
                    0xE => {
                        sp -= 1;
                        pc = stack[sp];
                    },
                    else => return error.UnknownOpcode,
                }
            },
            0x1000 => {
                pc = (opcode & 0x0FFF);
            },
            0x2000 => {
                stack[sp] = pc;
                sp += 1;
                pc = (opcode & 0x0FFF);
            },
            0x3000 => {
                if (registers[(opcode & 0x00FF)] == registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))]) {
                    pc += 2;
                }
            },
            0x4000 => {
                if (registers[@as(u4, @truncate(opcode & 0x00FF))] != registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))]) {
                    pc += 2;
                }
            },
            0x5000 => {
                if (registers[@as(u4, @truncate((opcode & 0x00F0) >> 4))] == registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))]) {
                    pc += 2;
                }
            },
            0x6000 => {
                registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))] = @as(u8, @truncate(opcode & 0x00FF));
            },
            0x7000 => {
                const vx = @as(u4, @truncate((opcode & 0x0F00) >> 8));
                _ = (@addWithOverflow(registers[vx], @as(u8, @truncate(opcode & 0x00FF))));

                registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))] += @truncate(opcode & 0x00FF);
            },
            0x8000 => {
                switch (opcode & 0xF) {
                    0x0 => {
                        registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))] = registers[@as(u4, @truncate((opcode & 0x00F0) >> 4))];
                    },
                    0x1 => {
                        registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))] |= registers[@as(u4, @truncate((opcode & 0x00F0) >> 4))];
                    },
                    0x2 => {
                        registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))] &= registers[@as(u4, @truncate((opcode & 0x00F0) >> 4))];
                    },
                    0x3 => {
                        registers[@as(u4, @truncate((opcode & 0x0F00) >> 8))] ^= registers[@as(u4, @truncate((opcode & 0x00F0) >> 4))];
                    },
                    0x4 => {},
                    0x5 => {},
                    0x6 => {},
                    0x7 => {},
                    0xE => {},
                    else => return error.UnknownOpcode,
                }
            },
            0x9000 => {
                if (registers[(opcode & 0x00F0)] != registers[(opcode & 0x0F00)]) {
                    pc += 2;
                }
            },
            0xA000 => {},
            0xB000 => {},
            0xC000 => {},
            0xD000 => {},
            0xE000 => {
                switch (opcode & 0xFF) {
                    0x9E => {},
                    0xA1 => {},
                    else => return error.UnknownOpcode,
                }
            },
            0xF000 => {
                switch (opcode & 0xFF) {
                    0x07 => {},
                    0x0A => {},
                    0x15 => {},
                    0x18 => {},
                    0x1E => {},
                    0x29 => {},
                    0x33 => {},
                    0x55 => {},
                    0x65 => {},
                    else => return error.UnknownOpcode,
                }
            },
            else => return error.UnknownOpcode,
        }
    }
    pub fn tick() void {
        std.debug.print("{}\n", .{Self.pc});
        const op: u16 = fetch();
        if (is_debug) {
            debug(op) catch |err| {
                std.debug.panic("Opcode not recognised: {}", .{err});
            };
        } else {
            execute(op) catch |err| {
                std.debug.panic("Opcode not recognised: {}", .{err});
            };
        }
    }

    pub fn debug(op: u16) !void {
        std.debug.print("{X}\n", .{op});
        for (registers) |reg| {
            std.debug.print("{X}\n", .{reg});
        }
        // try execute(op);
        execute(op) catch |err| {
            std.debug.print("Opcode was not recognised {}\n", .{err});
        };
        var buf: [1]u8 = [_]u8{0};
        _ = try std.io.getStdIn().reader().readUntilDelimiter(&buf, '\n');
    }
};

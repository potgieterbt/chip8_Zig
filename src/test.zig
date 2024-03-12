const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();
}

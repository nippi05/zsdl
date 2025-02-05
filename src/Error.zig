const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;

pub fn get() []const u8 {
    return std.mem.sliceTo(c.SDL_GetError(), 0);
}

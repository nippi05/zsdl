const std = @import("std");
const internal = @import("internal.zig");
const errify = @import("internal.zig").errify;
const c = @import("c.zig").c;

/// Set the SDL error message for the current thread.
pub inline fn setError(fmt: [:0]const u8, args: anytype) !void {
    try errify(c.SDL_SetError(fmt, args));
}

/// Set the SDL error message for the current thread.
pub inline fn setErrorV(fmt: [:0]const u8, args: anytype) !void {
    try errify(c.SDL_SetErrorV(fmt, args));
}

/// Set an error indicating that memory allocation failed.
pub inline fn outOfMemory() !void {
    try errify(c.SDL_OutOfMemory());
}

/// Retrieve a message about the last error that occurred on the current thread.
pub inline fn getError() []const u8 {
    return std.mem.span(c.SDL_GetError());
}

/// Clear any previous error message for this thread.
pub inline fn clearError() !void {
    try errify(c.SDL_ClearError());
}

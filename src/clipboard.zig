const std = @import("std");
const c = @import("c.zig").c;
const internal = @import("internal.zig");
const errify = internal.errify;

/// Put UTF-8 text into the clipboard.
pub inline fn setClipboardText(text: [*:0]const u8) !void {
    try errify(c.SDL_SetClipboardText(text));
}

/// Get UTF-8 text from the clipboard.
pub inline fn getClipboardText() ![]const u8 {
    const text = try errify(c.SDL_GetClipboardText());
    return std.mem.span(text);
}

/// Query whether the clipboard exists and contains a non-empty text string.
pub inline fn hasClipboardText() bool {
    return c.SDL_HasClipboardText();
}

/// Put UTF-8 text into the primary selection.
pub inline fn setPrimarySelectionText(text: [*:0]const u8) !void {
    try errify(c.SDL_SetPrimarySelectionText(text));
}

/// Get UTF-8 text from the primary selection.
pub inline fn getPrimarySelectionText() ![]const u8 {
    const text = try errify(c.SDL_GetPrimarySelectionText());
    return std.mem.span(text);
}

/// Query whether the primary selection exists and contains a non-empty text string.
pub inline fn hasPrimarySelectionText() bool {
    return c.SDL_HasPrimarySelectionText();
}

/// Offer clipboard data to the OS.
pub inline fn setClipboardData(
    callback: c.SDL_ClipboardDataCallback,
    cleanup: c.SDL_ClipboardCleanupCallback,
    userdata: ?*anyopaque,
    mime_types: [*c][*c]const u8,
    num_mime_types: usize,
) !void {
    try errify(c.SDL_SetClipboardData(callback, cleanup, userdata, mime_types, num_mime_types));
}

/// Clear the clipboard data.
pub inline fn clearClipboardData() !void {
    try errify(c.SDL_ClearClipboardData());
}

/// Get the data from clipboard for a given mime type.
pub inline fn getClipboardData(mime_type: [*:0]const u8) ![]const u8 {
    var size: usize = undefined;
    const data = c.SDL_GetClipboardData(mime_type, &size);
    try errify(data != null);
    return @as([*]const u8, @ptrCast(data))[0..size];
}

/// Query whether there is data in the clipboard for the provided mime type.
pub inline fn hasClipboardData(mime_type: [*:0]const u8) bool {
    return c.SDL_HasClipboardData(mime_type);
}

/// Retrieve the list of mime types available in the clipboard.
pub inline fn getClipboardMimeTypes() ![]const [*:0]const u8 {
    var num_mime_types: usize = undefined;
    const types = try errify(c.SDL_GetClipboardMimeTypes(&num_mime_types));
    return @as([*]const [*:0]const u8, @ptrCast(types))[0..@intCast(num_mime_types)];
}

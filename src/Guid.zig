const std = @import("std");

const c = @import("c.zig").c;
pub const GUID = c.SDL_GUID;

const Guid = @This();
data: [16]u8,

/// Converts the GUID to a string representation.
pub inline fn toString(self: *const Guid) ![33]u8 {
    var buf: [33]u8 = undefined; // 32 characters + null terminator
    _ = c.SDL_GUIDToString(@as(GUID, @bitCast(self.data)), &buf[0], buf.len);
    return buf;
}

/// Creates a GUID from a string representation.
pub inline fn fromString(guid: [:0]const u8) Guid {
    const sdl_guid = c.SDL_StringToGUID(guid);
    return .{ .data = @bitCast(sdl_guid) };
}

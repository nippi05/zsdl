const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const errify = internal.errify;
const video = @import("video.zig");
const Window = video.Window;
const rect = @import("rect.zig");
const Rectangle = rect.Rectangle;
const PropertiesID = video.PropertiesID;

pub const TouchID = c.SDL_TouchID;
pub const FingerID = c.SDL_FingerID;

pub const TouchDeviceType = enum(c_int) {
    invalid = c.SDL_TOUCH_DEVICE_INVALID,
    direct = c.SDL_TOUCH_DEVICE_DIRECT,
    indirect_absolute = c.SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE,
    indirect_relative = c.SDL_TOUCH_DEVICE_INDIRECT_RELATIVE,
};

pub const Finger = extern struct {
    id: FingerID,
    x: f32,
    y: f32,
    pressure: f32,
};

pub const Touch = struct {
    id: TouchID,

    pub fn getName(self: Touch) []const u8 {
        return std.mem.sliceTo(c.SDL_GetTouchDeviceName(self.id), 0);
    }

    pub fn getType(self: Touch) TouchDeviceType {
        return @enumFromInt(c.SDL_GetTouchDeviceType(self.id));
    }

    pub fn getFingers(self: Touch) ![]Finger {
        var count: c_int = undefined;
        const fingers = try errify(c.SDL_GetTouchFingers(self.id, &count));
        return @ptrCast(fingers[0..@intCast(count)]);
    }
};

pub fn getTouchDevices() ![]Touch {
    var count: c_int = undefined;
    const devices = try errify(c.SDL_GetTouchDevices(&count));
    return @ptrCast(devices[0..@intCast(count)]);
}

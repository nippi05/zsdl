const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
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

/// Get a list of registered touch devices.
pub fn getTouchDevices() ![]Touch {
    var count: c_int = undefined;
    const devices = try errify(c.SDL_GetTouchDevices(&count));
    return @ptrCast(devices[0..@intCast(count)]);
}

pub const Touch = struct {
    id: TouchID,

    /// Get the touch device name as reported from the driver.
    pub fn getName(self: Touch) []const u8 {
        return std.mem.sliceTo(c.SDL_GetTouchDeviceName(self.id), 0);
    }

    /// Get the type of the given touch device.
    pub fn getType(self: Touch) TouchDeviceType {
        return @enumFromInt(c.SDL_GetTouchDeviceType(self.id));
    }

    /// Get a list of active fingers for a given touch device.
    pub fn getFingers(self: Touch) ![]Finger {
        var count: c_int = undefined;
        const fingers = try errify(c.SDL_GetTouchFingers(self.id, &count));
        return @ptrCast(fingers[0..@intCast(count)]);
    }
};

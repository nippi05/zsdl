const std = @import("std");

const c = @import("c.zig").c;
pub const JoystickID = c.SDL_JoystickID;
pub const joystick_axis_max = c.SDL_JOYSTICK_AXIS_MAX;
pub const joystick_axis_min = c.SDL_JOYSTICK_AXIS_MIN;
pub const hat_centered = c.SDL_HAT_CENTERED;
pub const hat_up = c.SDL_HAT_UP;
pub const hat_right = c.SDL_HAT_RIGHT;
pub const hat_down = c.SDL_HAT_DOWN;
pub const hat_left = c.SDL_HAT_LEFT;
pub const hat_rightup = c.SDL_HAT_RIGHTUP;
pub const hat_rightdown = c.SDL_HAT_RIGHTDOWN;
pub const hat_leftup = c.SDL_HAT_LEFTUP;
pub const hat_leftdown = c.SDL_HAT_LEFTDOWN;
pub const prop_joystick_cap_mono_led = c.SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN;
pub const prop_joystick_cap_rgb_led = c.SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN;
pub const prop_joystick_cap_player_led = c.SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN;
pub const prop_joystick_cap_rumble = c.SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN;
pub const prop_joystick_cap_trigger_rumble = c.SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN;
const GUID = @import("Guid.zig").GUID;
const internal = @import("internal.zig");
const errify = internal.errify;
const errifyWithValue = internal.errifyWithValue;
const power = @import("power.zig");
const PowerState = power.PowerState;
const sensor = @import("sensor.zig");
const SensorType = sensor.SensorType;

pub const JoystickType = enum(u32) {
    unknown = c.SDL_JOYSTICK_TYPE_UNKNOWN,
    gamepad = c.SDL_JOYSTICK_TYPE_GAMEPAD,
    wheel = c.SDL_JOYSTICK_TYPE_WHEEL,
    arcade_stick = c.SDL_JOYSTICK_TYPE_ARCADE_STICK,
    flight_stick = c.SDL_JOYSTICK_TYPE_FLIGHT_STICK,
    dance_pad = c.SDL_JOYSTICK_TYPE_DANCE_PAD,
    guitar = c.SDL_JOYSTICK_TYPE_GUITAR,
    drum_kit = c.SDL_JOYSTICK_TYPE_DRUM_KIT,
    arcade_pad = c.SDL_JOYSTICK_TYPE_ARCADE_PAD,
    throttle = c.SDL_JOYSTICK_TYPE_THROTTLE,
    count = c.SDL_JOYSTICK_TYPE_COUNT,
};
pub const JoystickConnectionState = enum(i32) {
    invalid = c.SDL_JOYSTICK_CONNECTION_INVALID,
    unknown = c.SDL_JOYSTICK_CONNECTION_UNKNOWN,
    wired = c.SDL_JOYSTICK_CONNECTION_WIRED,
    wireless = c.SDL_JOYSTICK_CONNECTION_WIRELESS,
};

/// Get the implementation dependent name of a joystick.
pub inline fn getNameForID(instance_id: JoystickID) ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetJoystickNameForID(instance_id)));
}

/// Get the implementation dependent path of a joystick.
pub inline fn getPathForID(instance_id: JoystickID) ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetJoystickPathForID(instance_id)));
}

/// Get the player index of a joystick.
pub inline fn getPlayerIndexForID(instance_id: JoystickID) i32 {
    return c.SDL_GetJoystickPlayerIndexForID(instance_id);
}

/// Get the implementation-dependent GUID of a joystick.
pub inline fn getGUIDForID(instance_id: JoystickID) GUID {
    return c.SDL_GetJoystickGUIDForID(instance_id);
}

/// Get the USB vendor ID of a joystick, if available.
pub inline fn getVendorForID(instance_id: JoystickID) u16 {
    return c.SDL_GetJoystickVendorForID(instance_id);
}

/// Get the USB product ID of a joystick, if available.
pub inline fn getProductForID(instance_id: JoystickID) u16 {
    return c.SDL_GetJoystickProductForID(instance_id);
}

/// Get the product version of a joystick, if available.
pub inline fn getProductVersionForID(instance_id: JoystickID) u16 {
    return c.SDL_GetJoystickProductVersionForID(instance_id);
}

/// Get the type of a joystick, if available.
pub inline fn getTypeForID(instance_id: JoystickID) JoystickType {
    return @enumFromInt(c.SDL_GetJoystickTypeForID(instance_id));
}

/// Virtual joystick touchpad descriptor
pub const VirtualJoystickTouchpadDesc = extern struct {
    nfingers: u16,
    padding: [3]u16,
};

/// Virtual joystick sensor descriptor
pub const VirtualJoystickSensorDesc = extern struct {
    type: SensorType,
    rate: f32,
};

/// Virtual joystick descriptor
pub const VirtualJoystickDesc = extern struct {
    version: u32,
    type: u16,
    padding: u16,
    vendor_id: u16,
    product_id: u16,
    naxes: u16,
    nbuttons: u16,
    nballs: u16,
    nhats: u16,
    ntouchpads: u16,
    nsensors: u16,
    padding2: [2]u16,
    button_mask: u32,
    axis_mask: u32,
    name: [*:0]const u8,
    touchpads: ?[*]const VirtualJoystickTouchpadDesc,
    sensors: ?[*]const VirtualJoystickSensorDesc,
    userdata: ?*anyopaque,
    Update: ?*const fn (?*anyopaque) callconv(.C) void,
    SetPlayerIndex: ?*const fn (?*anyopaque, i32) callconv(.C) void,
    Rumble: ?*const fn (?*anyopaque, u16, u16) callconv(.C) bool,
    RumbleTriggers: ?*const fn (?*anyopaque, u16, u16) callconv(.C) bool,
    SetLED: ?*const fn (?*anyopaque, u8, u8, u8) callconv(.C) bool,
    SendEffect: ?*const fn (?*anyopaque, ?*const anyopaque, i32) callconv(.C) bool,
    SetSensorsEnabled: ?*const fn (?*anyopaque, bool) callconv(.C) bool,
    Cleanup: ?*const fn (?*anyopaque) callconv(.C) void,
};

pub const Joystick = struct {
    ptr: *c.SDL_Joystick,

    /// Open a joystick for use.
    pub inline fn open(instance_id: JoystickID) !Joystick {
        return .{
            .ptr = try errify(c.SDL_OpenJoystick(instance_id)),
        };
    }

    /// Get the SDL_Joystick associated with an instance ID, if it has been opened.
    pub inline fn getFromID(instance_id: JoystickID) !Joystick {
        return .{
            .ptr = try errify(c.SDL_GetJoystickFromID(instance_id)),
        };
    }

    /// Get the SDL_Joystick associated with a player index.
    pub inline fn getFromPlayerIndex(player_index: i32) !Joystick {
        return .{
            .ptr = try errify(c.SDL_GetJoystickFromPlayerIndex(player_index)),
        };
    }

    /// Get the implementation dependent name of a joystick.
    pub inline fn getName(self: *const Joystick) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetJoystickName(self.ptr)));
    }

    /// Get the implementation dependent path of a joystick.
    pub inline fn getPath(self: *const Joystick) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetJoystickPath(self.ptr)));
    }

    /// Get the player index of an opened joystick.
    pub inline fn getPlayerIndex(self: *const Joystick) i32 {
        return c.SDL_GetJoystickPlayerIndex(self.ptr);
    }

    /// Set the player index of an opened joystick.
    pub inline fn setPlayerIndex(self: *const Joystick, player_index: i32) !void {
        try errify(c.SDL_SetJoystickPlayerIndex(self.ptr, player_index));
    }

    /// Get the implementation-dependent GUID for the joystick.
    pub inline fn getGUID(self: *const Joystick) GUID {
        return c.SDL_GetJoystickGUID(self.ptr);
    }

    /// Get the USB vendor ID of an opened joystick, if available.
    pub inline fn getVendor(self: *const Joystick) u16 {
        return c.SDL_GetJoystickVendor(self.ptr);
    }

    /// Get the USB product ID of an opened joystick, if available.
    pub inline fn getProduct(self: *const Joystick) u16 {
        return c.SDL_GetJoystickProduct(self.ptr);
    }

    /// Get the product version of an opened joystick, if available.
    pub inline fn getProductVersion(self: *const Joystick) u16 {
        return c.SDL_GetJoystickProductVersion(self.ptr);
    }

    /// Get the firmware version of an opened joystick, if available.
    pub inline fn getFirmwareVersion(self: *const Joystick) u16 {
        return c.SDL_GetJoystickFirmwareVersion(self.ptr);
    }

    /// Get the serial number of an opened joystick, if available.
    pub inline fn getSerial(self: *const Joystick) ?[]const u8 {
        return if (c.SDL_GetJoystickSerial(self.ptr)) |serial| std.mem.span(serial) else null;
    }

    /// Get the type of an opened joystick.
    pub inline fn getType(self: *const Joystick) JoystickType {
        return @enumFromInt(c.SDL_GetJoystickType(self.ptr));
    }

    /// Get the properties associated with a joystick.
    pub inline fn getProperties(self: *const Joystick) c.SDL_PropertiesID {
        return c.SDL_GetJoystickProperties(self.ptr);
    }

    /// Get the status of a specified joystick.
    pub inline fn isConnected(self: *const Joystick) bool {
        return c.SDL_JoystickConnected(self.ptr);
    }

    /// Get the instance ID of an opened joystick.
    pub inline fn getID(self: *const Joystick) !JoystickID {
        return try errify(c.SDL_GetJoystickID(self.ptr));
    }

    /// Get the number of general axis controls on a joystick.
    pub inline fn getNumAxes(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickAxes(self.ptr));
    }

    /// Get the number of trackballs on a joystick.
    pub inline fn getNumBalls(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickBalls(self.ptr));
    }

    /// Get the number of POV hats on a joystick.
    pub inline fn getNumHats(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickHats(self.ptr));
    }

    /// Get the number of buttons on a joystick.
    pub inline fn getNumButtons(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickButtons(self.ptr));
    }

    /// Get the current state of an axis control on a joystick.
    pub inline fn getAxis(self: *const Joystick, axis: i32) !i16 {
        return try errify(c.SDL_GetJoystickAxis(self.ptr, axis));
    }

    /// Get the initial state of an axis control on a joystick.
    pub inline fn getAxisInitialState(self: *const Joystick, axis: i32, state: *i16) bool {
        return c.SDL_GetJoystickAxisInitialState(self.ptr, axis, state);
    }

    /// Get the ball axis change since the last poll.
    pub inline fn getBall(self: *const Joystick, ball: i32, dx: *i32, dy: *i32) !void {
        try errify(c.SDL_GetJoystickBall(self.ptr, ball, dx, dy));
    }

    /// Get the current state of a POV hat on a joystick.
    pub inline fn getHat(self: *const Joystick, hat: i32) u8 {
        return c.SDL_GetJoystickHat(self.ptr, hat);
    }

    /// Get the current state of a button on a joystick.
    pub inline fn getButton(self: *const Joystick, button: i32) bool {
        return c.SDL_GetJoystickButton(self.ptr, button);
    }

    /// Start a rumble effect.
    pub inline fn rumble(self: *const Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) !void {
        try errify(c.SDL_RumbleJoystick(self.ptr, low_frequency_rumble, high_frequency_rumble, duration_ms));
    }

    /// Start a rumble effect in the joystick's triggers.
    pub inline fn rumbleTriggers(self: *const Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) !void {
        try errify(c.SDL_RumbleJoystickTriggers(self.ptr, left_rumble, right_rumble, duration_ms));
    }

    /// Update a joystick's LED color.
    pub inline fn setLED(self: *const Joystick, red: u8, green: u8, blue: u8) !void {
        try errify(c.SDL_SetJoystickLED(self.ptr, red, green, blue));
    }

    /// Send a joystick specific effect packet.
    pub inline fn sendEffect(self: *const Joystick, data: *const anyopaque, size: i32) !void {
        try errify(c.SDL_SendJoystickEffect(self.ptr, data, size));
    }

    /// Set the state of an axis on an opened virtual joystick.
    pub inline fn setVirtualAxis(self: *const Joystick, axis: i32, value: i16) !void {
        return try errify(c.SDL_SetJoystickVirtualAxis(self.ptr, axis, value));
    }

    /// Generate ball motion on an opened virtual joystick.
    pub inline fn setVirtualBall(self: *const Joystick, ball: i32, xrel: i16, yrel: i16) !void {
        return try errify(c.SDL_SetJoystickVirtualBall(self.ptr, ball, xrel, yrel));
    }

    /// Set the state of a button on an opened virtual joystick.
    pub inline fn setVirtualButton(self: *const Joystick, button: i32, down: bool) !void {
        return try errify(c.SDL_SetJoystickVirtualButton(self.ptr, button, down));
    }

    /// Set the state of a hat on an opened virtual joystick.
    pub inline fn setVirtualHat(self: *const Joystick, hat: i32, value: u8) !void {
        return try errify(c.SDL_SetJoystickVirtualHat(self.ptr, hat, value));
    }

    /// Set touchpad finger state on an opened virtual joystick.
    pub inline fn setVirtualTouchpad(
        self: *const Joystick,
        touchpad: i32,
        finger: i32,
        down: bool,
        x: f32,
        y: f32,
        pressure: f32,
    ) !void {
        return try errify(c.SDL_SetJoystickVirtualTouchpad(
            self.ptr,
            touchpad,
            finger,
            down,
            x,
            y,
            pressure,
        ));
    }

    /// Send a sensor update for an opened virtual joystick.
    pub inline fn sendVirtualSensorData(
        self: *const Joystick,
        @"type": SensorType,
        sensor_timestamp: u64,
        data: []const f32,
    ) !void {
        return try errify(c.SDL_SendJoystickVirtualSensorData(
            self.ptr,
            @intFromEnum(@"type"),
            sensor_timestamp,
            @ptrCast(data.ptr),
            @intCast(data.len),
        ));
    }

    /// Close a joystick previously opened with SDL_OpenJoystick().
    pub inline fn close(self: *const Joystick) void {
        c.SDL_CloseJoystick(self.ptr);
    }

    /// Get the connection state of a joystick.
    pub inline fn getConnectionState(self: *const Joystick) !JoystickConnectionState {
        return @enumFromInt(try errifyWithValue(
            c.SDL_GetJoystickConnectionState(self.ptr),
            c.SDL_JOYSTICK_CONNECTION_INVALID,
        ));
    }

    /// Get the battery state of a joystick.
    pub inline fn getPowerInfo(self: *const Joystick, percent: *i32) !PowerState {
        return @enumFromInt(try errifyWithValue(
            c.SDL_GetJoystickPowerInfo(self.ptr, percent),
            c.SDL_POWERSTATE_ERROR,
        ));
    }
};

/// Locking for atomic access to the joystick API.
pub inline fn lockJoysticks() void {
    c.SDL_LockJoysticks();
}

/// Unlocking for atomic access to the joystick API.
pub inline fn unlockJoysticks() void {
    c.SDL_UnlockJoysticks();
}

/// Return whether a joystick is currently connected.
pub inline fn hasJoystick() bool {
    return c.SDL_HasJoystick();
}

/// Get a list of currently connected joysticks.
pub inline fn getJoysticks() ![]JoystickID {
    var count: c_int = undefined;
    const joysticks = try errify(c.SDL_GetJoysticks(&count));
    return joysticks[0..@intCast(count)];
}

/// Attach a new virtual joystick.
pub inline fn attachVirtualJoystick(desc: *const VirtualJoystickDesc) !JoystickID {
    return try errify(c.SDL_AttachVirtualJoystick(@ptrCast(desc)));
}

/// Detach a virtual joystick.
pub inline fn detachVirtualJoystick(instance_id: JoystickID) !void {
    try errify(c.SDL_DetachVirtualJoystick(instance_id));
}

/// Query whether or not a joystick is virtual.
pub inline fn isJoystickVirtual(instance_id: JoystickID) bool {
    return c.SDL_IsJoystickVirtual(instance_id);
}

/// Set the state of joystick event processing.
pub inline fn setJoystickEventsEnabled(enabled: bool) void {
    c.SDL_SetJoystickEventsEnabled(enabled);
}

/// Query the state of joystick event processing.
pub inline fn joystickEventsEnabled() bool {
    return c.SDL_JoystickEventsEnabled();
}

/// Update the current state of the open joysticks.
pub inline fn updateJoysticks() void {
    c.SDL_UpdateJoysticks();
}

const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;
const errifyWithValue = internal.errifyWithValue;
const power = @import("power.zig");
const PowerState = power.PowerState;

pub const JoystickID = c.SDL_JoystickID;
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
};
pub const JoystickConnectionState = enum(i32) {
    invalid = c.SDL_JOYSTICK_CONNECTION_INVALID,
    unknown = c.SDL_JOYSTICK_CONNECTION_UNKNOWN,
    wired = c.SDL_JOYSTICK_CONNECTION_WIRED,
    wireless = c.SDL_JOYSTICK_CONNECTION_WIRELESS,
};

/// Get the implementation dependent name of a joystick.
pub fn getNameForID(instance_id: JoystickID) ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetJoystickNameForID(instance_id)));
}

/// Get the implementation dependent path of a joystick.
pub fn getPathForID(instance_id: JoystickID) ![]const u8 {
    return try errify(c.SDL_GetJoystickPathForID(instance_id));
}

/// Get the player index of a joystick.
pub fn getPlayerIndexForID(instance_id: JoystickID) i32 {
    return c.SDL_GetJoystickPlayerIndexForID(instance_id);
}

/// Get the implementation-dependent GUID of a joystick.
pub fn getGUIDForID(instance_id: JoystickID) c.SDL_GUID {
    return c.SDL_GetJoystickGUIDForID(instance_id);
}

/// Get the USB vendor ID of a joystick, if available.
pub fn getVendorForID(instance_id: JoystickID) u16 {
    return c.SDL_GetJoystickVendorForID(instance_id);
}

/// Get the USB product ID of a joystick, if available.
pub fn getProductForID(instance_id: JoystickID) u16 {
    return c.SDL_GetJoystickProductForID(instance_id);
}

/// Get the product version of a joystick, if available.
pub fn getProductVersionForID(instance_id: JoystickID) u16 {
    return c.SDL_GetJoystickProductVersionForID(instance_id);
}

/// Get the type of a joystick, if available.
pub fn getTypeForID(instance_id: JoystickID) JoystickType {
    return @enumFromInt(c.SDL_GetJoystickTypeForID(instance_id));
}

pub const Joystick = struct {
    ptr: *c.SDL_Joystick,

    /// Open a joystick for use.
    pub fn open(instance_id: JoystickID) !Joystick {
        return Joystick{ .ptr = try errify(c.SDL_OpenJoystick(instance_id)) };
    }

    /// Get the SDL_Joystick associated with an instance ID, if it has been opened.
    pub fn getFromID(instance_id: JoystickID) !Joystick {
        return Joystick{ .ptr = try errify(c.SDL_GetJoystickFromID(instance_id)) };
    }

    /// Get the SDL_Joystick associated with a player index.
    pub fn getFromPlayerIndex(player_index: i32) !Joystick {
        return Joystick{ .ptr = try errify(c.SDL_GetJoystickFromPlayerIndex(player_index)) };
    }

    /// Get the implementation dependent name of a joystick.
    pub fn getName(self: *const Joystick) ![]const u8 {
        return try errify(c.SDL_GetJoystickName(self.ptr));
    }

    /// Get the implementation dependent path of a joystick.
    pub fn getPath(self: *const Joystick) ![]const u8 {
        return try errify(c.SDL_GetJoystickPath(self.ptr));
    }

    /// Get the player index of an opened joystick.
    pub fn getPlayerIndex(self: *const Joystick) i32 {
        return c.SDL_GetJoystickPlayerIndex(self.ptr);
    }

    /// Set the player index of an opened joystick.
    pub fn setPlayerIndex(self: *const Joystick, player_index: i32) !void {
        try errify(c.SDL_SetJoystickPlayerIndex(self.ptr, player_index));
    }

    /// Get the implementation-dependent GUID for the joystick.
    pub fn getGUID(self: *const Joystick) c.SDL_GUID {
        return c.SDL_GetJoystickGUID(self.ptr);
    }

    /// Get the USB vendor ID of an opened joystick, if available.
    pub fn getVendor(self: *const Joystick) u16 {
        return c.SDL_GetJoystickVendor(self.ptr);
    }

    /// Get the USB product ID of an opened joystick, if available.
    pub fn getProduct(self: *const Joystick) u16 {
        return c.SDL_GetJoystickProduct(self.ptr);
    }

    /// Get the product version of an opened joystick, if available.
    pub fn getProductVersion(self: *const Joystick) u16 {
        return c.SDL_GetJoystickProductVersion(self.ptr);
    }

    /// Get the firmware version of an opened joystick, if available.
    pub fn getFirmwareVersion(self: *const Joystick) u16 {
        return c.SDL_GetJoystickFirmwareVersion(self.ptr);
    }

    /// Get the serial number of an opened joystick, if available.
    pub fn getSerial(self: *const Joystick) ?[]const u8 {
        return c.SDL_GetJoystickSerial(self.ptr);
    }

    /// Get the type of an opened joystick.
    pub fn getType(self: *const Joystick) JoystickType {
        return @enumFromInt(c.SDL_GetJoystickType(self.ptr));
    }

    /// Get the status of a specified joystick.
    pub fn isConnected(self: *const Joystick) bool {
        return c.SDL_JoystickConnected(self.ptr);
    }

    /// Get the instance ID of an opened joystick.
    pub fn getID(self: *const Joystick) !JoystickID {
        return try errify(c.SDL_GetJoystickID(self.ptr));
    }

    /// Get the number of general axis controls on a joystick.
    pub fn getNumAxes(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickAxes(self.ptr));
    }

    /// Get the number of trackballs on a joystick.
    pub fn getNumBalls(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickBalls(self.ptr));
    }

    /// Get the number of POV hats on a joystick.
    pub fn getNumHats(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickHats(self.ptr));
    }

    /// Get the number of buttons on a joystick.
    pub fn getNumButtons(self: *const Joystick) !i32 {
        return try errify(c.SDL_GetNumJoystickButtons(self.ptr));
    }

    /// Get the current state of an axis control on a joystick.
    pub fn getAxis(self: *const Joystick, axis: i32) i16 {
        return c.SDL_GetJoystickAxis(self.ptr, axis);
    }

    /// Get the initial state of an axis control on a joystick.
    pub fn getAxisInitialState(self: *const Joystick, axis: i32, state: *i16) bool {
        return c.SDL_GetJoystickAxisInitialState(self.ptr, axis, state);
    }

    /// Get the ball axis change since the last poll.
    pub fn getBall(self: *const Joystick, ball: i32, dx: *i32, dy: *i32) !void {
        try errify(c.SDL_GetJoystickBall(self.ptr, ball, dx, dy));
    }

    /// Get the current state of a POV hat on a joystick.
    pub fn getHat(self: *const Joystick, hat: i32) u8 {
        return c.SDL_GetJoystickHat(self.ptr, hat);
    }

    /// Get the current state of a button on a joystick.
    pub fn getButton(self: *const Joystick, button: i32) bool {
        return c.SDL_GetJoystickButton(self.ptr, button);
    }

    /// Start a rumble effect.
    pub fn rumble(self: *const Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) !void {
        try errify(c.SDL_RumbleJoystick(self.ptr, low_frequency_rumble, high_frequency_rumble, duration_ms));
    }

    /// Start a rumble effect in the joystick's triggers.
    pub fn rumbleTriggers(self: *const Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) !void {
        try errify(c.SDL_RumbleJoystickTriggers(self.ptr, left_rumble, right_rumble, duration_ms));
    }

    /// Update a joystick's LED color.
    pub fn setLED(self: *const Joystick, red: u8, green: u8, blue: u8) !void {
        try errify(c.SDL_SetJoystickLED(self.ptr, red, green, blue));
    }

    /// Send a joystick specific effect packet.
    pub fn sendEffect(self: *const Joystick, data: *const anyopaque, size: i32) !void {
        try errify(c.SDL_SendJoystickEffect(self.ptr, data, size));
    }

    /// Close a joystick previously opened with SDL_OpenJoystick().
    pub fn close(self: *const Joystick) void {
        c.SDL_CloseJoystick(self.ptr);
    }

    /// Get the connection state of a joystick.
    pub fn getConnectionState(self: *const Joystick) !JoystickConnectionState {
        return @enumFromInt(try errifyWithValue(
            c.SDL_GetJoystickConnectionState(self.ptr),
            c.SDL_JOYSTICK_CONNECTION_INVALID,
        ));
    }

    /// Get the battery state of a joystick.
    pub fn getPowerInfo(self: *const Joystick, percent: *i32) !PowerState {
        return @enumFromInt(try errifyWithValue(
            c.SDL_GetJoystickPowerInfo(self.ptr, percent),
            c.SDL_POWERSTATE_ERROR,
        ));
    }
};

/// Locking for atomic access to the joystick API.
pub fn lockJoysticks() void {
    c.SDL_LockJoysticks();
}

/// Unlocking for atomic access to the joystick API.
pub fn unlockJoysticks() void {
    c.SDL_UnlockJoysticks();
}

/// Return whether a joystick is currently connected.
pub fn hasJoystick() bool {
    return c.SDL_HasJoystick();
}

/// Get a list of currently connected joysticks.
pub fn getJoysticks(count: *c_int) ![]JoystickID {
    const joysticks = try errify(c.SDL_GetJoysticks(count));
    return @ptrCast(joysticks[0..@intCast(count.*)]);
}

/// Attach a new virtual joystick.
pub fn attachVirtualJoystick(desc: *const c.SDL_VirtualJoystickDesc) !JoystickID {
    return try errify(c.SDL_AttachVirtualJoystick(desc));
}

/// Detach a virtual joystick.
pub fn detachVirtualJoystick(instance_id: JoystickID) !void {
    try errify(c.SDL_DetachVirtualJoystick(instance_id));
}

/// Query whether or not a joystick is virtual.
pub fn isJoystickVirtual(instance_id: JoystickID) bool {
    return c.SDL_IsJoystickVirtual(instance_id);
}

/// Set the state of joystick event processing.
pub fn setJoystickEventsEnabled(enabled: bool) void {
    c.SDL_SetJoystickEventsEnabled(enabled);
}

/// Query the state of joystick event processing.
pub fn joystickEventsEnabled() bool {
    return c.SDL_JoystickEventsEnabled();
}

/// Update the current state of the open joysticks.
pub fn updateJoysticks() void {
    c.SDL_UpdateJoysticks();
}

const std = @import("std");

const c = @import("c.zig").c;
pub const HapticID = c.SDL_HapticID;
const internal = @import("internal.zig");
const errify = internal.errify;
const errifyWithValue = internal.errifyWithValue;
const Joystick = @import("joystick.zig").Joystick;

pub const HapticDirectionType = enum(u8) {
    polar = c.SDL_HAPTIC_POLAR,
    cartesian = c.SDL_HAPTIC_CARTESIAN,
    spherical = c.SDL_HAPTIC_SPHERICAL,
    steering_axis = c.SDL_HAPTIC_STEERING_AXIS,
};

pub const HapticDirection = extern struct {
    type: HapticDirectionType = std.mem.zeroes(HapticDirectionType),
    dir: [3]i32 = [_]i32{0} ** 3,

    pub inline fn north() HapticDirection {
        return .{
            .type = .polar,
            .dir = [_]i32{ 0, 0, 0 },
        };
    }

    pub inline fn east() HapticDirection {
        return .{
            .type = .polar,
            .dir = [_]i32{ 9000, 0, 0 },
        };
    }

    pub inline fn south() HapticDirection {
        return .{
            .type = .polar,
            .dir = [_]i32{ 18000, 0, 0 },
        };
    }

    pub inline fn west() HapticDirection {
        return .{
            .type = .polar,
            .dir = [_]i32{ 27000, 0, 0 },
        };
    }

    pub inline fn cartesian(x: i32, y: i32, z: i32) HapticDirection {
        return .{
            .type = .cartesian,
            .dir = [_]i32{ x, y, z },
        };
    }
};

pub const HapticEffectType = enum(u16) {
    constant = c.SDL_HAPTIC_CONSTANT,
    sine = c.SDL_HAPTIC_SINE,
    square = c.SDL_HAPTIC_SQUARE,
    triangle = c.SDL_HAPTIC_TRIANGLE,
    sawtoothup = c.SDL_HAPTIC_SAWTOOTHUP,
    sawtoothdown = c.SDL_HAPTIC_SAWTOOTHDOWN,
    ramp = c.SDL_HAPTIC_RAMP,
    spring = c.SDL_HAPTIC_SPRING,
    damper = c.SDL_HAPTIC_DAMPER,
    inertia = c.SDL_HAPTIC_INERTIA,
    friction = c.SDL_HAPTIC_FRICTION,
    leftright = c.SDL_HAPTIC_LEFTRIGHT,
    custom = c.SDL_HAPTIC_CUSTOM,
};

pub const HapticConstant = extern struct {
    type: HapticEffectType,
    direction: HapticDirection = std.mem.zeroes(HapticDirection),
    length: u32 = std.mem.zeroes(u32),
    delay: u16 = std.mem.zeroes(u16),
    button: u16 = std.mem.zeroes(u16),
    interval: u16 = std.mem.zeroes(u16),
    level: i16 = std.mem.zeroes(i16),
    attack_length: u16 = std.mem.zeroes(u16),
    attack_level: u16 = std.mem.zeroes(u16),
    fade_length: u16 = std.mem.zeroes(u16),
    fade_level: u16 = std.mem.zeroes(u16),
};

pub const HapticPeriodic = extern struct {
    type: HapticEffectType,
    direction: HapticDirection = std.mem.zeroes(HapticDirection),
    length: u32 = std.mem.zeroes(u32),
    delay: u16 = std.mem.zeroes(u16),
    button: u16 = std.mem.zeroes(u16),
    interval: u16 = std.mem.zeroes(u16),
    period: u16 = std.mem.zeroes(u16),
    magnitude: i16 = std.mem.zeroes(i16),
    offset: i16 = std.mem.zeroes(i16),
    phase: u16 = std.mem.zeroes(u16),
    attack_length: u16 = std.mem.zeroes(u16),
    attack_level: u16 = std.mem.zeroes(u16),
    fade_length: u16 = std.mem.zeroes(u16),
    fade_level: u16 = std.mem.zeroes(u16),
};

pub const HapticCondition = extern struct {
    type: HapticEffectType,
    direction: HapticDirection = std.mem.zeroes(HapticDirection),
    length: u32 = std.mem.zeroes(u32),
    delay: u16 = std.mem.zeroes(u16),
    button: u16 = std.mem.zeroes(u16),
    interval: u16 = std.mem.zeroes(u16),
    right_sat: [3]u16 = [_]u16{0} ** 3,
    left_sat: [3]u16 = [_]u16{0} ** 3,
    right_coeff: [3]i16 = [_]i16{0} ** 3,
    left_coeff: [3]i16 = [_]i16{0} ** 3,
    deadband: [3]u16 = [_]u16{0} ** 3,
    center: [3]i16 = [_]i16{0} ** 3,
};

pub const HapticRamp = extern struct {
    type: HapticEffectType,
    direction: HapticDirection = std.mem.zeroes(HapticDirection),
    length: u32 = std.mem.zeroes(u32),
    delay: u16 = std.mem.zeroes(u16),
    button: u16 = std.mem.zeroes(u16),
    interval: u16 = std.mem.zeroes(u16),
    start: i16 = std.mem.zeroes(i16),
    end: i16 = std.mem.zeroes(i16),
    attack_length: u16 = std.mem.zeroes(u16),
    attack_level: u16 = std.mem.zeroes(u16),
    fade_length: u16 = std.mem.zeroes(u16),
    fade_level: u16 = std.mem.zeroes(u16),
};

pub const HapticLeftRight = extern struct {
    type: HapticEffectType,
    length: u32 = std.mem.zeroes(u32),
    large_magnitude: u16 = std.mem.zeroes(u16),
    small_magnitude: u16 = std.mem.zeroes(u16),
};

pub const HapticCustom = extern struct {
    type: HapticEffectType,
    direction: HapticDirection = std.mem.zeroes(HapticDirection),
    length: u32 = std.mem.zeroes(u32),
    delay: u16 = std.mem.zeroes(u16),
    button: u16 = std.mem.zeroes(u16),
    interval: u16 = std.mem.zeroes(u16),
    channels: u8 = std.mem.zeroes(u8),
    period: u16 = std.mem.zeroes(u16),
    samples: u16 = std.mem.zeroes(u16),
    data: [*]allowzero u16 = std.mem.zeroes([*]allowzero u16),
    attack_length: u16 = std.mem.zeroes(u16),
    attack_level: u16 = std.mem.zeroes(u16),
    fade_length: u16 = std.mem.zeroes(u16),
    fade_level: u16 = std.mem.zeroes(u16),
};

pub const HapticEffect = union(HapticEffectType) {
    constant: HapticConstant,
    sine: HapticPeriodic,
    square: HapticPeriodic,
    triangle: HapticPeriodic,
    sawtoothup: HapticPeriodic,
    sawtoothdown: HapticPeriodic,
    ramp: HapticRamp,
    spring: HapticCondition,
    damper: HapticCondition,
    inertia: HapticCondition,
    friction: HapticCondition,
    leftright: HapticLeftRight,
    custom: HapticCustom,
};

pub const Haptic = extern struct {
    ptr: *c.SDL_Haptic,

    /// Get the instance ID of an opened haptic device.
    pub inline fn getID(self: *const Haptic) HapticID {
        return c.SDL_GetHapticID(self.ptr);
    }

    /// Get the implementation dependent name of a haptic device.
    pub inline fn getName(self: *const Haptic) ?[*:0]const u8 {
        return c.SDL_GetHapticName(self.ptr);
    }

    /// Close a haptic device previously opened with SDL_OpenHaptic().
    pub inline fn close(self: *const Haptic) void {
        c.SDL_CloseHaptic(self.ptr);
    }

    /// Get the number of effects a haptic device can store.
    pub inline fn getMaxEffects(self: *const Haptic) !c_int {
        return try errify(c.SDL_GetMaxHapticEffects(self.ptr));
    }

    /// Get the number of effects a haptic device can play at the same time.
    pub inline fn getMaxEffectsPlaying(self: *const Haptic) !c_int {
        return try errify(c.SDL_GetMaxHapticEffectsPlaying(self.ptr));
    }

    /// Get the haptic device's supported features in bitwise manner.
    pub inline fn getFeatures(self: *const Haptic) u32 {
        return c.SDL_GetHapticFeatures(self.ptr);
    }

    /// Get the number of haptic axes the device has.
    pub inline fn getNumAxes(self: *const Haptic) !c_int {
        return try errify(c.SDL_GetNumHapticAxes(self.ptr));
    }

    /// Check to see if an effect is supported by a haptic device.
    pub inline fn effectSupported(self: *const Haptic, effect: *const HapticEffect) bool {
        return c.SDL_HapticEffectSupported(self.ptr, @ptrCast(effect));
    }

    /// Create a new haptic effect on a specified device.
    pub inline fn createEffect(self: *const Haptic, effect: *const HapticEffect) !c_int {
        return try errifyWithValue(c.SDL_CreateHapticEffect(self.ptr, @ptrCast(effect)), -1);
    }

    /// Update the properties of an effect.
    pub inline fn updateEffect(self: *const Haptic, effect: c_int, data: *const HapticEffect) !void {
        try errify(c.SDL_UpdateHapticEffect(self.ptr, effect, @ptrCast(data)));
    }

    /// Run the haptic effect on its associated haptic device.
    pub inline fn runEffect(self: *const Haptic, effect: c_int, iterations: u32) !void {
        try errify(c.SDL_RunHapticEffect(self.ptr, effect, iterations));
    }

    /// Stop the haptic effect on its associated haptic device.
    pub inline fn stopEffect(self: *const Haptic, effect: c_int) !void {
        try errify(c.SDL_StopHapticEffect(self.ptr, effect));
    }

    /// Destroy a haptic effect on the device.
    pub inline fn destroyEffect(self: *const Haptic, effect: c_int) void {
        c.SDL_DestroyHapticEffect(self.ptr, effect);
    }

    /// Get the status of the current effect on the specified haptic device.
    pub inline fn getEffectStatus(self: *const Haptic, effect: c_int) bool {
        return c.SDL_GetHapticEffectStatus(self.ptr, effect);
    }

    /// Set the global gain of the specified haptic device.
    pub inline fn setGain(self: *const Haptic, gain: c_int) !void {
        try errify(c.SDL_SetHapticGain(self.ptr, gain));
    }

    /// Set the global autocenter of the device.
    pub inline fn setAutocenter(self: *const Haptic, autocenter: c_int) !void {
        try errify(c.SDL_SetHapticAutocenter(self.ptr, autocenter));
    }

    /// Pause a haptic device.
    pub inline fn pause(self: *const Haptic) !void {
        try errify(c.SDL_PauseHaptic(self.ptr));
    }

    /// Resume a haptic device.
    pub inline fn @"resume"(self: *const Haptic) !void {
        try errify(c.SDL_ResumeHaptic(self.ptr));
    }

    /// Stop all the currently playing effects on a haptic device.
    pub inline fn stopEffects(self: *const Haptic) !void {
        try errify(c.SDL_StopHapticEffects(self.ptr));
    }

    /// Check whether rumble is supported on a haptic device.
    pub inline fn rumbleSupported(self: *const Haptic) bool {
        return c.SDL_HapticRumbleSupported(self.ptr);
    }

    /// Initialize a haptic device for simple rumble playback.
    pub inline fn initRumble(self: *const Haptic) !void {
        try errify(c.SDL_InitHapticRumble(self.ptr));
    }

    /// Run a simple rumble effect on a haptic device.
    pub inline fn playRumble(self: *const Haptic, strength: f32, length: u32) !void {
        try errify(c.SDL_PlayHapticRumble(self.ptr, strength, length));
    }

    /// Stop the simple rumble on a haptic device.
    pub inline fn stopRumble(self: *const Haptic) !void {
        try errify(c.SDL_StopHapticRumble(self.ptr));
    }
};

/// Get a list of currently connected haptic devices.
pub inline fn getHaptics() ![]HapticID {
    var count: c_int = undefined;
    const haptic_ids = try errify(c.SDL_GetHaptics(&count));
    return haptic_ids[0..@intCast(count)];
}

/// Get the implementation dependent name of a haptic device.
pub inline fn getHapticNameForID(instance_id: HapticID) ?[*:0]const u8 {
    return c.SDL_GetHapticNameForID(instance_id);
}

/// Open a haptic device for use.
pub inline fn openHaptic(instance_id: HapticID) !Haptic {
    return .{
        .ptr = try errify(c.SDL_OpenHaptic(instance_id)),
    };
}

/// Get the SDL_Haptic associated with an instance ID, if it has been opened.
pub inline fn getHapticFromID(instance_id: HapticID) ?Haptic {
    if (c.SDL_GetHapticFromID(instance_id)) |ptr| {
        return Haptic{ .ptr = ptr };
    }
    return null;
}

/// Query whether or not the current mouse has haptic capabilities.
pub inline fn isMouseHaptic() bool {
    return c.SDL_IsMouseHaptic();
}

/// Try to open a haptic device from the current mouse.
pub inline fn openHapticFromMouse() !Haptic {
    return .{
        .ptr = try errify(c.SDL_OpenHapticFromMouse()),
    };
}

/// Query if a joystick has haptic features.
pub inline fn isJoystickHaptic(joystick: *Joystick) bool {
    return c.SDL_IsJoystickHaptic(joystick.ptr);
}

/// Open a haptic device for use from a joystick device.
pub inline fn openHapticFromJoystick(joystick: *Joystick) !Haptic {
    return .{
        .ptr = try errify(c.SDL_OpenHapticFromJoystick(joystick.ptr)),
    };
}

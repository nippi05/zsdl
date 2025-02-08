const std = @import("std");
const internal = @import("internal.zig");
const Joystick = @import("joystick.zig").Joystick;
const c = internal.c;
const errify = internal.errify;

pub const HapticID = c.SDL_HapticID;
pub const HapticEffect = c.SDL_HapticEffect;

pub const Haptic = struct {
    ptr: *c.SDL_Haptic,

    /// Get a list of currently connected haptic devices.
    pub fn getHaptics(count: *c_int) ![*]HapticID {
        return try errify(c.SDL_GetHaptics(count));
    }

    /// Get the implementation dependent name of a haptic device.
    pub fn getHapticNameForID(instance_id: HapticID) ?[*:0]const u8 {
        return c.SDL_GetHapticNameForID(instance_id);
    }

    /// Open a haptic device for use.
    pub fn openHaptic(instance_id: HapticID) !Haptic {
        const ptr = try errify(c.SDL_OpenHaptic(instance_id));
        return Haptic{ .ptr = ptr };
    }

    /// Get the SDL_Haptic associated with an instance ID, if it has been opened.
    pub fn getHapticFromID(instance_id: HapticID) ?Haptic {
        if (c.SDL_GetHapticFromID(instance_id)) |ptr| {
            return Haptic{ .ptr = ptr };
        }
        return null;
    }

    /// Get the instance ID of an opened haptic device.
    pub fn getID(self: *const Haptic) HapticID {
        return c.SDL_GetHapticID(self.ptr);
    }

    /// Get the implementation dependent name of a haptic device.
    pub fn getName(self: *const Haptic) ?[*:0]const u8 {
        return c.SDL_GetHapticName(self.ptr);
    }

    /// Try to open a haptic device from the current mouse.
    pub fn openHapticFromMouse() !Haptic {
        const ptr = try errify(c.SDL_OpenHapticFromMouse());
        return Haptic{ .ptr = ptr };
    }

    /// Query if a joystick has haptic features.
    pub fn isJoystickHaptic(joystick: *Joystick) bool {
        return c.SDL_IsJoystickHaptic(joystick.ptr);
    }

    /// Open a haptic device for use from a joystick device.
    pub fn openHapticFromJoystick(joystick: *Joystick) !Haptic {
        const ptr = try errify(c.SDL_OpenHapticFromJoystick(joystick.ptr));
        return Haptic{ .ptr = ptr };
    }

    /// Close a haptic device previously opened with SDL_OpenHaptic().
    pub fn close(self: *const Haptic) void {
        c.SDL_CloseHaptic(self.ptr);
    }

    /// Get the number of effects a haptic device can store.
    pub fn getMaxEffects(self: *const Haptic) !c_int {
        return try errify(c.SDL_GetMaxHapticEffects(self.ptr));
    }

    /// Get the number of effects a haptic device can play at the same time.
    pub fn getMaxEffectsPlaying(self: *const Haptic) !c_int {
        return try errify(c.SDL_GetMaxHapticEffectsPlaying(self.ptr));
    }

    /// Get the haptic device's supported features in bitwise manner.
    pub fn getFeatures(self: *const Haptic) u32 {
        return c.SDL_GetHapticFeatures(self.ptr);
    }

    /// Get the number of haptic axes the device has.
    pub fn getNumAxes(self: *const Haptic) !c_int {
        return try errify(c.SDL_GetNumHapticAxes(self.ptr));
    }

    /// Check to see if an effect is supported by a haptic device.
    pub fn effectSupported(self: *const Haptic, effect: *const HapticEffect) bool {
        return c.SDL_HapticEffectSupported(self.ptr, effect);
    }

    /// Create a new haptic effect on a specified device.
    pub fn createEffect(self: *const Haptic, effect: *const HapticEffect) !c_int {
        return try errify(c.SDL_CreateHapticEffect(self.ptr, effect));
    }

    /// Update the properties of an effect.
    pub fn updateEffect(self: *const Haptic, effect: c_int, data: *const HapticEffect) !void {
        try errify(c.SDL_UpdateHapticEffect(self.ptr, effect, data));
    }

    /// Run the haptic effect on its associated haptic device.
    pub fn runEffect(self: *const Haptic, effect: c_int, iterations: u32) !void {
        try errify(c.SDL_RunHapticEffect(self.ptr, effect, iterations));
    }

    /// Stop the haptic effect on its associated haptic device.
    pub fn stopEffect(self: *const Haptic, effect: c_int) !void {
        try errify(c.SDL_StopHapticEffect(self.ptr, effect));
    }

    /// Destroy a haptic effect on the device.
    pub fn destroyEffect(self: *const Haptic, effect: c_int) void {
        c.SDL_DestroyHapticEffect(self.ptr, effect);
    }

    /// Get the status of the current effect on the specified haptic device.
    pub fn getEffectStatus(self: *const Haptic, effect: c_int) bool {
        return c.SDL_GetHapticEffectStatus(self.ptr, effect);
    }

    /// Set the global gain of the specified haptic device.
    pub fn setGain(self: *const Haptic, gain: c_int) !void {
        try errify(c.SDL_SetHapticGain(self.ptr, gain));
    }

    /// Set the global autocenter of the device.
    pub fn setAutocenter(self: *const Haptic, autocenter: c_int) !void {
        try errify(c.SDL_SetHapticAutocenter(self.ptr, autocenter));
    }

    /// Pause a haptic device.
    pub fn pause(self: *const Haptic) !void {
        try errify(c.SDL_PauseHaptic(self.ptr));
    }

    /// Resume a haptic device.
    pub fn @"resume"(self: *const Haptic) !void {
        try errify(c.SDL_ResumeHaptic(self.ptr));
    }

    /// Stop all the currently playing effects on a haptic device.
    pub fn stopEffects(self: *const Haptic) !void {
        try errify(c.SDL_StopHapticEffects(self.ptr));
    }

    /// Check whether rumble is supported on a haptic device.
    pub fn rumbleSupported(self: *const Haptic) bool {
        return c.SDL_HapticRumbleSupported(self.ptr);
    }

    /// Initialize a haptic device for simple rumble playback.
    pub fn initRumble(self: *const Haptic) !void {
        try errify(c.SDL_InitHapticRumble(self.ptr));
    }

    /// Run a simple rumble effect on a haptic device.
    pub fn playRumble(self: *const Haptic, strength: f32, length: u32) !void {
        try errify(c.SDL_PlayHapticRumble(self.ptr, strength, length));
    }

    /// Stop the simple rumble on a haptic device.
    pub fn stopRumble(self: *const Haptic) !void {
        try errify(c.SDL_StopHapticRumble(self.ptr));
    }
};

/// Query whether or not the current mouse has haptic capabilities.
pub fn isMouseHaptic() bool {
    return c.SDL_IsMouseHaptic();
}

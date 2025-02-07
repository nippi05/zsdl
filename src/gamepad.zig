const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const errify = internal.errify;

pub const GamepadType = enum(u32) {
    unknown = c.SDL_GAMEPAD_TYPE_UNKNOWN,
    standard = c.SDL_GAMEPAD_TYPE_STANDARD,
    xbox360 = c.SDL_GAMEPAD_TYPE_XBOX360,
    xboxone = c.SDL_GAMEPAD_TYPE_XBOXONE,
    ps3 = c.SDL_GAMEPAD_TYPE_PS3,
    ps4 = c.SDL_GAMEPAD_TYPE_PS4,
    ps5 = c.SDL_GAMEPAD_TYPE_PS5,
    nintendo_switch_pro = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO,
    nintendo_switch_joycon_left = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT,
    nintendo_switch_joycon_right = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT,
    nintendo_switch_joycon_pair = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR,
};

pub const Gamepad = struct {
    ptr: *c.SDL_Gamepad,

    // /// Open a gamepad for use.
    // pub fn openGamepad(SDL_JoystickID instance_id)SDL_Gamepad * {}

    // /// Get the SDL_Gamepad associated with a joystick instance ID, if it has been opened.
    // pub fn getGamepadFromID(SDL_JoystickID instance_id)SDL_Gamepad * {}

    /// Get the SDL_Gamepad associated with a player index.
    pub fn getGamepadFromPlayerIndex(player_index: c_int) !Gamepad {
        return .{
            .ptr = try errify(c.SDL_GetGamepadFromPlayerIndex(player_index)),
        };
    }

    /// Get the current mapping of a gamepad.
    pub fn getMapping(self: *const Gamepad) ![]const u8 {
        return std.mem.sliceTo(try errify(c.SDL_GetGamepadMapping(self.ptr)), 0);
    }

    // /// Get the properties associated with an opened gamepad.
    // pub fn getProperties(self: *const Gamepad)SDL_PropertiesID {}

    // /// Get the instance ID of an opened gamepad.
    // pub fn getID(self: *const Gamepad)SDL_JoystickID {}

    // /// Get the implementation-dependent name for an opened gamepad.
    // pub fn getName(self: *const Gamepad)[]const u8 {}

    // /// Get the implementation-dependent path for an opened gamepad.
    // pub fn getPath(self: *const Gamepad)[]const u8 {}

    // /// Get the type of an opened gamepad.
    // pub fn getType(self: *const Gamepad)GamepadType {}

    // /// Get the type of an opened gamepad, ignoring any mapping override.
    // pub fn getRealType(self: *const Gamepad)GamepadType {}

    // /// Get the player index of an opened gamepad.
    // pub fn getPlayerIndex(self: *const Gamepad)int {}

    // /// Set the player index of an opened gamepad.
    // pub fn setPlayerIndex(self: *const Gamepad, int player_index)bool {}

    // /// Get the USB vendor ID of an opened gamepad, if available.
    // pub fn getVendor(self: *const Gamepad)u16 {}

    // /// Get the USB product ID of an opened gamepad, if available.
    // pub fn getProduct(self: *const Gamepad)u16 {}

    // /// Get the product version of an opened gamepad, if available.
    // pub fn getProductVersion(self: *const Gamepad)u16 {}

    // /// Get the firmware version of an opened gamepad, if available.
    // pub fn getFirmwareVersion(self: *const Gamepad)u16 {
    //     return c.SDL_GetGamepadFirmwareVersion(self.ptr);
    // }

    // /// Get the serial number of an opened gamepad, if available.
    // pub fn getSerial(self: *const Gamepad)[]const u8 {}

    // /// Get the Steam Input handle of an opened gamepad, if available.
    // pub fn getSteamHandle(self: *const Gamepad)u64 {}

    // /// Get the connection state of a gamepad.
    // pub fn getConnectionState(self: *const Gamepad)SDL_JoystickConnection{}

    // /// Get the battery state of a gamepad.
    // pub fn getPowerInfo(self: *const Gamepad, int *percent)SDL_Power{}

    // /// Check if a gamepad has been opened and is currently connected.
    // pub fn connected(self: *const Gamepad)bool {}

    // /// Get the underlying joystick from a gamepad.
    // pub fn getJoystick(self: *const Gamepad)SDL_Joystick * {}

    // /// Get the SDL joystick layer bindings for a gamepad.
    // pub fn getBindings(self: *const Gamepad, int *count)SDL_GamepadBinding ** {}

    // /// Query whether a gamepad has a given axis.
    // pub fn hasAxis(self: *const Gamepad, SDL_GamepadAxis axis)bool {}

    // /// Get the current state of an axis control on a gamepad.
    // pub fn getAxis(self: *const Gamepad, SDL_GamepadAxis axis)i16 {}

    // /// Query whether a gamepad has a given button.
    // pub fn hasButton(self: *const Gamepad, SDL_GamepadButton button)bool {}

    // /// Get the current state of a button on a gamepad.
    // pub fn getButton(self: *const Gamepad, SDL_GamepadButton button)bool {}

    // /// Get the label of a button on a gamepad.
    // pub fn getButtonLabel(self: *const Gamepad, SDL_GamepadButton button)SDL_GamepadButtonLabel {}

    // /// Get the number of touchpads on a gamepad.
    // pub fn getNumTouchpads(self: *const Gamepad)int {}

    // /// Get the number of supported simultaneous fingers on a touchpad on a game gamepad.
    // pub fn getNumTouchpadFingers(self: *const Gamepad, int touchpad)int {}

    // /// Get the current state of a finger on a touchpad on a gamepad.
    // pub fn getTouchpadFinger(self: *const Gamepad, int touchpad, int finger, bool *down, f32 *x, f32 *y, f32 *pressure)bool {}

    // /// Return whether a gamepad has a particular sensor.
    // pub fn hasSensor(self: *const Gamepad, SDL_SensorType type)bool {}

    // /// Set whether data reporting for a gamepad sensor is enabled.
    // pub fn setSensorEnabled(self: *const Gamepad, SDL_SensorType type, bool enabled)bool {}

    // /// Query whether sensor data reporting is enabled for a gamepad.
    // pub fn sensorEnabled(self: *const Gamepad, SDL_SensorType type)bool {}

    // /// Get the data rate (number of events per second) of a gamepad sensor.
    // pub fn getSensorDataRate(self: *const Gamepad, SDL_SensorType type)f32 {}

    // /// Get the current state of a gamepad sensor.
    // pub fn getSensorData(self: *const Gamepad, SDL_SensorType type, f32 *data, int num_values)bool {}

    // /// Start a rumble effect on a gamepad.
    // pub fn rumble(self: *const Gamepad, u16 low_frequency_rumble, u16 high_frequency_rumble, u32 duration_ms)bool {}

    // /// Start a rumble effect in the gamepad's triggers.
    // pub fn rumbleTriggers(self: *const Gamepad, u16 left_rumble, u16 right_rumble, u32 duration_ms)bool {}

    // /// Update a gamepad's LED color.
    // pub fn setLED(self: *const Gamepad, Uint8 red, Uint8 green, Uint8 blue)bool {}

    // /// Send a gamepad specific effect packet.
    // pub fn sendEffect(self: *const Gamepad, const void *data, int size)bool {}

    // /// Close a gamepad previously opened with SDL_OpenGamepad().
    // pub fn close(self: *const Gamepad)void {}

    // /// Return the sfSymbolsName for a given button on a gamepad on Apple platforms.
    // pub fn getAppleSFSymbolsNameForButton(self: *const Gamepad, SDL_GamepadButton button)[]const u8 {}

    // /// Return the sfSymbolsName for a given axis on a gamepad on Apple platforms.
    // pub fn getAppleSFSymbolsNameForAxis(self: *const Gamepad, SDL_GamepadAxis axis)[]const u8 {}

    // /// Return the sfSymbolsName for a given axis on a gamepad on Apple platforms.
    // pub fn getAppleSFSymbolsNameForAxis(self: *const Gamepad, SDL_GamepadAxis axis)[]const u8 {}

};

// /// Add support for gamepads that SDL is unaware of or change the binding of an existing gamepad.
// pub fn addGamepadMapping(const char *mapping)int {}

// /// Load a set of gamepad mappings from an SDL_IOStream.
// pub fn addGamepadMappingsFromIO(SDL_IOStream *src, bool closeio)int {}

// /// Load a set of gamepad mappings from a file.
// pub fn addGamepadMappingsFromFile(const char *file)int {}

// /// Reinitialize the SDL mapping database to its initial state.
// pub fn reloadGamepadMappings() bool {}

// /// Get the current gamepad mappings.
// pub fn getGamepadMappings(int *count)char ** {}

// /// Get the gamepad mapping string for a given GUID.
// pub fn getGamepadMappingForGUID(SDL_GUID guid)char * {}

// /// Set the current mapping of a joystick or gamepad.
// pub fn setGamepadMapping(SDL_JoystickID instance_id, const char *mapping)bool {}

// /// Return whether a gamepad is currently connected.
// pub fn hasGamepad() bool {}

// /// Get a list of currently connected gamepads.
// pub fn getGamepads(int *count)SDL_JoystickID * {}

// /// Check if the given joystick is supported by the gamepad interface.
// pub fn isGamepad(SDL_JoystickID instance_id)bool {}

// /// Get the implementation dependent name of a gamepad.
// pub fn getGamepadNameForID(SDL_JoystickID instance_id)const char * {}

// /// Get the implementation dependent path of a gamepad.
// pub fn getGamepadPathForID(SDL_JoystickID instance_id)const char * {}

// /// Get the player index of a gamepad.
// pub fn getGamepadPlayerIndexForID(SDL_JoystickID instance_id)int {}

// /// Get the implementation-dependent GUID of a gamepad.
// pub fn getGamepadGUIDForID(SDL_JoystickID instance_id)SDL_GUID {}

// /// Get the USB vendor ID of a gamepad, if available.
// pub fn getGamepadVendorForID(SDL_JoystickID instance_id)u16 {}

// /// Get the USB product ID of a gamepad, if available.
// pub fn getGamepadProductForID(SDL_JoystickID instance_id)u16 {}

// /// Get the product version of a gamepad, if available.
// pub fn getGamepadProductVersionForID(SDL_JoystickID instance_id)u16 {}

// /// Get the type of a gamepad.
// pub fn getGamepadTypeForID(SDL_JoystickID instance_id)GamepadType {}

// /// Get the type of a gamepad, ignoring any mapping override.
// pub fn getRealGamepadTypeForID(SDL_JoystickID instance_id)GamepadType {}

// /// Get the mapping of a gamepad.
// pub fn getGamepadMappingForID(SDL_JoystickID instance_id)char * {}

// /// Set the state of gamepad event processing.
// pub fn setGamepadEventsEnabled(bool enabled)void {}

// /// Query the state of gamepad event processing.
// pub fn gamepadEventsEnabled() bool {}

// /// Manually pump gamepad updates if not using the loop.
// pub fn updateGamepads() void {}

// /// Convert a string into GamepadType enum.
// pub fn getGamepadTypeFromString(const char *str)GamepadType {}

// /// Convert from an GamepadType enum to a string.
// pub fn getGamepadStringForType(GamepadType type)const char * {}

// /// Convert a string into SDL_GamepadAxis enum.
// pub fn getGamepadAxisFromString(const char *str)SDL_GamepadAxis {}

// /// Convert from an SDL_GamepadAxis enum to a string.
// pub fn getGamepadStringForAxis(SDL_GamepadAxis axis)const char * {}

// /// Convert a string into an SDL_GamepadButton enum.
// pub fn getGamepadButtonFromString(const char *str)SDL_GamepadButton {}

// /// Convert from an SDL_GamepadButton enum to a string.
// pub fn getGamepadStringForButton(SDL_GamepadButton button)const char * {}

// /// Get the label of a button on a gamepad.
// pub fn getGamepadButtonLabelForType(GamepadType type, SDL_GamepadButton button)SDL_GamepadButtonLabel {}

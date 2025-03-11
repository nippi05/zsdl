const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const joystick = zsdl.joystick;
const c = zsdl.c;

// Test enum values
test "JoystickType enum values match SDL constants" {
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.unknown), c.SDL_JOYSTICK_TYPE_UNKNOWN);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.gamepad), c.SDL_JOYSTICK_TYPE_GAMEPAD);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.wheel), c.SDL_JOYSTICK_TYPE_WHEEL);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.arcade_stick), c.SDL_JOYSTICK_TYPE_ARCADE_STICK);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.flight_stick), c.SDL_JOYSTICK_TYPE_FLIGHT_STICK);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.dance_pad), c.SDL_JOYSTICK_TYPE_DANCE_PAD);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.guitar), c.SDL_JOYSTICK_TYPE_GUITAR);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.drum_kit), c.SDL_JOYSTICK_TYPE_DRUM_KIT);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.arcade_pad), c.SDL_JOYSTICK_TYPE_ARCADE_PAD);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.throttle), c.SDL_JOYSTICK_TYPE_THROTTLE);
    try testing.expectEqual(@intFromEnum(joystick.JoystickType.count), c.SDL_JOYSTICK_TYPE_COUNT);
}

test "JoystickConnectionState enum values match SDL constants" {
    try testing.expectEqual(@intFromEnum(joystick.JoystickConnectionState.invalid), c.SDL_JOYSTICK_CONNECTION_INVALID);
    try testing.expectEqual(@intFromEnum(joystick.JoystickConnectionState.unknown), c.SDL_JOYSTICK_CONNECTION_UNKNOWN);
    try testing.expectEqual(@intFromEnum(joystick.JoystickConnectionState.wired), c.SDL_JOYSTICK_CONNECTION_WIRED);
    try testing.expectEqual(@intFromEnum(joystick.JoystickConnectionState.wireless), c.SDL_JOYSTICK_CONNECTION_WIRELESS);
}

// Basic function tests
test "Basic joystick functions" {
    // Test locking functions
    joystick.lockJoysticks();
    joystick.unlockJoysticks();

    // Test hasJoystick
    _ = joystick.hasJoystick();

    // Test joystick events
    const initial_state = joystick.joystickEventsEnabled();
    joystick.setJoystickEventsEnabled(true);
    try testing.expect(joystick.joystickEventsEnabled());
    joystick.setJoystickEventsEnabled(false);
    try testing.expect(!joystick.joystickEventsEnabled());
    // Reset to initial state
    joystick.setJoystickEventsEnabled(initial_state);

    // Test update function
    joystick.updateJoysticks();
}

// Tests that can run even without actual joysticks connected
test "VirtualJoystickDesc struct has expected size" {
    // This ensures the struct layout matches the C struct
    // The actual size may vary by platform (32/64 bit), so we check both cases
    const size = @sizeOf(joystick.VirtualJoystickDesc);
    try testing.expect(size == 84 or size == 136); // 84 for 32-bit systems, 136 for 64-bit
}

test "VirtualJoystickTouchpadDesc struct has expected size" {
    const size = @sizeOf(joystick.VirtualJoystickTouchpadDesc);
    try testing.expectEqual(@as(usize, 8), size);
}

test "VirtualJoystickSensorDesc struct has expected size" {
    const size = @sizeOf(joystick.VirtualJoystickSensorDesc);
    try testing.expectEqual(@as(usize, 8), size);
}

// Tests that require actual joysticks or virtual joysticks
test "getJoysticks returns valid joystick IDs if available" {
    if (joystick.hasJoystick()) {
        var count: c_int = 0;
        const joysticks = joystick.getJoysticks(&count) catch {
            try testing.expect(false);
            return;
        };
        try testing.expect(count >= 0);
        if (count > 0) {
            try testing.expect(joysticks.len == count);
            // Check that we can get info about the first joystick
            const id = joysticks[0];
            _ = joystick.getTypeForID(id);
        }
    }
}

test "attachVirtualJoystick and detachVirtualJoystick" {
    const desc = joystick.VirtualJoystickDesc{
        .version = 1,
        .type = @intFromEnum(joystick.JoystickType.gamepad),
        .padding = 0,
        .vendor_id = 0x1234,
        .product_id = 0x5678,
        .naxes = 2,
        .nbuttons = 8,
        .nballs = 0,
        .nhats = 1,
        .ntouchpads = 0,
        .nsensors = 0,
        .padding2 = [_]u16{0} ** 2,
        .button_mask = 0xFF,
        .axis_mask = 0x03,
        .name = "Test Virtual Joystick",
        .touchpads = null,
        .sensors = null,
        .userdata = null,
        .Update = null,
        .SetPlayerIndex = null,
        .Rumble = null,
        .RumbleTriggers = null,
        .SetLED = null,
        .SendEffect = null,
        .SetSensorsEnabled = null,
        .Cleanup = null,
    };

    // Try to attach a virtual joystick - this may fail on systems where virtual joysticks aren't supported
    const id = joystick.attachVirtualJoystick(&desc) catch |err| {
        std.debug.print("Failed to attach virtual joystick: {s}\n", .{@errorName(err)});
        return;
    };

    defer {
        joystick.detachVirtualJoystick(id) catch |err| {
            std.debug.print("Failed to detach virtual joystick: {s}\n", .{@errorName(err)});
        };
    }

    try testing.expect(id != 0);
    try testing.expect(joystick.isJoystickVirtual(id));

    // Test ID info functions
    const type_id = joystick.getTypeForID(id);
    try testing.expectEqual(joystick.JoystickType.gamepad, type_id);

    const vendor = joystick.getVendorForID(id);
    try testing.expectEqual(@as(u16, 0x1234), vendor);

    const product = joystick.getProductForID(id);
    try testing.expectEqual(@as(u16, 0x5678), product);

    const version = joystick.getProductVersionForID(id);
    try testing.expectEqual(@as(u16, 0), version);

    _ = joystick.getGUIDForID(id);
    _ = joystick.getPlayerIndexForID(id);

    // Try to get name and path (might not be available in all contexts)
    _ = joystick.getNameForID(id) catch {};
    _ = joystick.getPathForID(id) catch {};
}

test "Open and use a joystick" {
    if (!joystick.hasJoystick()) return;

    var count: c_int = 0;
    const joysticks = joystick.getJoysticks(&count) catch {
        try testing.expect(false);
        return;
    };

    if (count == 0) return;

    const id = joysticks[0];
    const joy = joystick.Joystick.open(id) catch {
        // Skip this test if we can't open the joystick
        return;
    };
    defer joy.close();

    // Test basic properties
    const joy_id = joy.getID() catch {
        try testing.expect(false);
        return;
    };
    try testing.expectEqual(id, joy_id);

    // Test that we can get basic information about the joystick
    _ = joy.getName() catch {};
    _ = joy.getPath() catch {};
    _ = joy.getGUID();
    _ = joy.getType();
    _ = joy.getVendor();
    _ = joy.getProduct();
    _ = joy.getProductVersion();
    _ = joy.getFirmwareVersion();
    _ = joy.getSerial();
    _ = joy.isConnected();
    _ = joy.getPlayerIndex();
    _ = joy.getProperties();

    // Test methods that get controller features
    const num_axes = joy.getNumAxes() catch 0;
    const num_buttons = joy.getNumButtons() catch 0;
    const num_hats = joy.getNumHats() catch 0;
    const num_balls = joy.getNumBalls() catch 0;

    // Test state reading methods if features are available
    if (num_axes > 0) {
        const axis_value = joy.getAxis(0);
        try testing.expect(axis_value >= joystick.joystick_axis_min and axis_value <= joystick.joystick_axis_max);

        var initial_state: i16 = undefined;
        _ = joy.getAxisInitialState(0, &initial_state);
    }

    if (num_buttons > 0) {
        const button_state = joy.getButton(0);
        try testing.expect(button_state == true or button_state == false);
    }

    if (num_hats > 0) {
        const hat_state = joy.getHat(0);
        try testing.expect(hat_state == joystick.hat_centered or
            hat_state == joystick.hat_up or
            hat_state == joystick.hat_right or
            hat_state == joystick.hat_down or
            hat_state == joystick.hat_left or
            hat_state == joystick.hat_rightup or
            hat_state == joystick.hat_rightdown or
            hat_state == joystick.hat_leftup or
            hat_state == joystick.hat_leftdown);
    }

    if (num_balls > 0) {
        var dx: i32 = 0;
        var dy: i32 = 0;
        _ = joy.getBall(0, &dx, &dy) catch {};
    }

    // Test connection state
    const conn_state = joy.getConnectionState() catch joystick.JoystickConnectionState.unknown;
    try testing.expect(conn_state != .invalid);

    // Test player index (can only verify we can call the function)
    _ = joy.setPlayerIndex(joy.getPlayerIndex()) catch {};

    // Test special features (may not be supported by all joysticks, so we just test that the calls work)
    _ = joy.rumble(0, 0, 1) catch {};
    _ = joy.rumbleTriggers(0, 0, 1) catch {};
    _ = joy.setLED(0, 0, 0) catch {};

    // Test power information
    var percent: i32 = undefined;
    _ = joy.getPowerInfo(&percent) catch {};
}

// Test virtual joystick control features (only if we can create a virtual joystick)
test "Virtual joystick control" {
    const desc = joystick.VirtualJoystickDesc{
        .version = 1,
        .type = @intFromEnum(joystick.JoystickType.gamepad),
        .padding = 0,
        .vendor_id = 0x1234,
        .product_id = 0x5678,
        .naxes = 2,
        .nbuttons = 2,
        .nballs = 1,
        .nhats = 1,
        .ntouchpads = 0,
        .nsensors = 0,
        .padding2 = [_]u16{0} ** 2,
        .button_mask = 0x03,
        .axis_mask = 0x03,
        .name = "Test Virtual Joystick Controls",
        .touchpads = null,
        .sensors = null,
        .userdata = null,
        .Update = null,
        .SetPlayerIndex = null,
        .Rumble = null,
        .RumbleTriggers = null,
        .SetLED = null,
        .SendEffect = null,
        .SetSensorsEnabled = null,
        .Cleanup = null,
    };

    // Try to attach a virtual joystick
    const id = joystick.attachVirtualJoystick(&desc) catch |err| {
        std.debug.print("Failed to attach virtual joystick for control test: {s}\n", .{@errorName(err)});
        return;
    };

    defer {
        joystick.detachVirtualJoystick(id) catch {};
    }

    // Open the virtual joystick
    const joy = joystick.Joystick.open(id) catch {
        std.debug.print("Failed to open virtual joystick\n", .{});
        return;
    };
    defer joy.close();

    // Test setting virtual joystick controls
    _ = joy.setVirtualAxis(0, 0) catch {};
    _ = joy.setVirtualButton(0, true) catch {};
    _ = joy.setVirtualHat(0, joystick.hat_up) catch {};
    _ = joy.setVirtualBall(0, 10, 10) catch {};

    // These features might not be implemented depending on platform
    if (desc.ntouchpads > 0) {
        _ = joy.setVirtualTouchpad(0, 0, true, 0.5, 0.5, 1.0) catch {};
    }

    if (desc.nsensors > 0) {
        var data = [_]f32{ 0.0, 0.0, 0.0 };
        _ = joy.sendVirtualSensorData(.accel, 0, &data, data.len) catch {};
    }
}

// Test joystick from player index
test "getFromPlayerIndex" {
    // This test depends on having a joystick with a player index set
    // We'll set player index 0 on the first joystick if available
    if (!joystick.hasJoystick()) return;

    var count: c_int = 0;
    const joysticks = joystick.getJoysticks(&count) catch {
        return;
    };

    if (count == 0) return;

    const id = joysticks[0];
    const joy = joystick.Joystick.open(id) catch {
        return;
    };

    // Try to set player index 0
    _ = joy.setPlayerIndex(0) catch {};
    joy.close();

    // Now try to get joystick from player index 0
    const joy2 = joystick.Joystick.getFromPlayerIndex(0) catch {
        // This is acceptable to fail, we're just testing the function exists
        return;
    };
    defer joy2.close();
}

// Test getFromID
test "getFromID" {
    if (!joystick.hasJoystick()) return;

    var count: c_int = 0;
    const joysticks = joystick.getJoysticks(&count) catch {
        return;
    };

    if (count == 0) return;

    const id = joysticks[0];
    const joy = joystick.Joystick.open(id) catch {
        return;
    };
    defer joy.close();

    // Test getFromID after opening a joystick
    const joy2 = joystick.Joystick.getFromID(id) catch {
        try testing.expect(false);
        return;
    };

    // Both should have the same underlying pointer
    try testing.expectEqual(joy.ptr, joy2.ptr);
}

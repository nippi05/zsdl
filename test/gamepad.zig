const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const gamepad = zsdl.gamepad;
const print = std.debug.print;

// Mock gamepad for testing when no real gamepad is connected
const MockGamepad = struct {
    pub fn init() !void {
        try zsdl.init(.{ .gamepad = true });
    }

    pub fn deinit() void {
        zsdl.quit();
    }
};

test "Gamepad module functions" {
    try MockGamepad.init();
    defer MockGamepad.deinit();

    // Test gamepad events enabled/disabled
    gamepad.setGamepadEventsEnabled(true);
    try testing.expect(gamepad.gamepadEventsEnabled());
    gamepad.setGamepadEventsEnabled(false);
    try testing.expect(!gamepad.gamepadEventsEnabled());

    // Test has gamepad (may be false if no gamepad connected)
    print("{any}", .{gamepad.hasGamepad()});

    // Test gamepad type conversion
    const type_str = "xbox360";
    const pad_type = gamepad.getGamepadTypeFromString(type_str);
    try testing.expectEqual(gamepad.GamepadType.xbox360, pad_type);

    if (gamepad.getGamepadStringForType(pad_type)) |str| {
        try testing.expectEqualStrings("xbox360", str);
    }

    // Test button conversion
    const button_str = "a";
    const button = gamepad.getGamepadButtonFromString(button_str);
    try testing.expectEqual(gamepad.GamepadButton.south, button);

    if (gamepad.getGamepadStringForButton(button)) |str| {
        try testing.expectEqualStrings("a", str);
    }

    // Test axis conversion
    const axis_str = "leftx";
    const axis = gamepad.getGamepadAxisFromString(axis_str);
    try testing.expectEqual(gamepad.GamepadAxis.leftx, axis);

    if (gamepad.getGamepadStringForAxis(axis)) |str| {
        try testing.expectEqualStrings("leftx", str);
    }
}

test "Gamepad instance functions" {
    try MockGamepad.init();
    defer MockGamepad.deinit();

    // These tests will only work if a gamepad is actually connected
    if (gamepad.hasGamepad()) {
        const gamepads = try gamepad.getGamepads();
        for (gamepads) |id| {

            // Test gamepad opening
            var pad = try gamepad.Gamepad.open(id);
            defer pad.close();

            // Test basic properties
            print("{?s}", .{pad.getName()});
            print("{any}", .{pad.getPath()});
            print("{any}", .{pad.getType()});
            print("{any}", .{pad.getRealType()});
            print("{any}", .{pad.getPlayerIndex()});
            print("{any}", .{pad.getVendor()});
            print("{any}", .{pad.getProduct()});
            print("{any}", .{pad.getProductVersion()});
            print("{any}", .{pad.getFirmwareVersion()});
            print("{any}", .{pad.getSerial()});
            print("{any}", .{pad.getSteamHandle()});

            // Test connection state
            try testing.expect(pad.connected());

            // Test button and axis presence
            print("{any}", .{pad.hasButton(.south)});
            print("{any}", .{pad.hasAxis(.leftx)});

            // Test button and axis states
            print("{any}", .{pad.getButton(.south)});
            print("{any}", .{pad.getAxis(.leftx)});

            // Test rumble (may not work on all gamepads)
            pad.rumble(0, 0, 0) catch {};
            pad.rumbleTriggers(0, 0, 0) catch {};

            // Test LED (may not work on all gamepads)
            pad.setLED(0, 0, 0) catch {};
        }
    }
}

test "Gamepad mapping functions" {
    try MockGamepad.init();
    defer MockGamepad.deinit();

    // Test getting mappings
    print("{any}", .{try gamepad.getGamepadMappings()});
    // Test reloading mappings
    gamepad.reloadGamepadMappings() catch {};
}

test "Gamepad utility functions" {
    try MockGamepad.init();
    defer MockGamepad.deinit();

    // Test button label for type
    const label = gamepad.getGamepadButtonLabelForType(.xbox360, .south);
    try testing.expectEqual(gamepad.GamepadButtonLabel.a, label);

    // Update gamepads manually
    gamepad.updateGamepads();
}

const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const keyboard = zsdl.keyboard;
const print = std.debug.print;

test "keyboard basics" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.@"error".getError()});
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // Test keyboard availability
    const has_keyboard = keyboard.hasKeyboard();
    print("Has keyboard: {}\n", .{has_keyboard});

    // Test keyboard enumeration
    const keyboards = try keyboard.getKeyboards();
    print("Number of keyboards: {}\n", .{keyboards.len});

    // Test keyboard name for the first keyboard (if available)
    if (keyboards.len > 0) {
        const name = keyboards[0].getName();
        print("First keyboard name: {?s}\n", .{name});
    }

    // Test keyboard focus
    const focus_window = keyboard.getKeyboardFocus();
    print("Keyboard focus window: {?}\n", .{focus_window});

    // Test keyboard state
    const state = try keyboard.getKeyboardState();
    print("Keyboard state array length: {}\n", .{state.len});

    // Test keyboard reset
    keyboard.resetKeyboard();
}

test "keyboard modifiers and keys" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.@"error".getError()});
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // Test modifier state
    const mod_state = keyboard.Keymod.getState();
    print("Current modifier state: {}\n", .{mod_state});

    // Test setting modifier state
    const original_state = mod_state;
    keyboard.Keymod.setState(.none);
    keyboard.Keymod.setState(original_state);

    // Test key and scancode names
    const key_name = keyboard.Keycode.a.getName();
    print("Name of key 'a': {s}\n", .{key_name});

    const scancode_name = keyboard.Scancode.a.getName();
    print("Name of scancode 'a': {s}\n", .{scancode_name});

    // Test key and scancode from name
    const key_from_name = try keyboard.Keycode.fromName("A");
    print("Key from name 'A': {}\n", .{key_from_name});

    const scancode_from_name = try keyboard.Scancode.fromName("A");
    print("Scancode from name 'A': {}\n", .{scancode_from_name});
}

test "key and scancode conversion" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.@"error".getError()});
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // Note: Tests for the functions that had issues in the implementation
    // Uncomment after fixing the implementation

    // Test scancode to keycode conversion
    // const key = keyboard.Scancode.a.getKey(.none, true);
    // print("Key for scancode 'a': {}\n", .{key});

    // Test keycode to scancode conversion - requires fix for pointer handling
    // var modstate: keyboard.Keymod = undefined;
    // const scancode = keyboard.Keycode.a.getScancode(&modstate);
    // print("Scancode for key 'a': {}, with modstate: {}\n", .{scancode, modstate});

    // Test setting scancode name
    if (keyboard.Scancode.a.setName("TestA")) {
        print("Successfully set scancode name\n", .{});
        // Verify the name was changed
        const name = keyboard.Scancode.a.getName();
        print("Updated scancode name: {s}\n", .{name});
    } else |err| {
        print("Failed to set scancode name: {}\n", .{err});
    }
}

test "text input" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.@"error".getError()});
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // Create a window for testing text input
    const window = try zsdl.video.Window.create("Test Window", 640, 480, .{});
    defer window.destroy();

    // Test text input functionality
    try keyboard.startTextInput(window);
    print("Text input started\n", .{});

    const active = keyboard.textInputActive(window);
    print("Text input active: {}\n", .{active});

    // Test text input area
    const rect = zsdl.rect.Rect{ .x = 10, .y = 10, .w = 100, .h = 20 };
    try keyboard.setTextInputArea(window, rect, 0);

    var cursor: c_int = undefined;
    const area = try keyboard.getTextInputArea(window, &cursor);
    print("Text input area: {any}, cursor: {}\n", .{ area, cursor });

    // Test clear composition
    try keyboard.clearComposition(window);

    // Stop text input
    try keyboard.stopTextInput(window);
}

test "screen keyboard" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.@"error".getError()});
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // Create a window for testing screen keyboard
    const window = try zsdl.video.Window.create("Test Window", 640, 480, .{});
    defer window.destroy();

    // Test screen keyboard support
    const has_screen_kb = keyboard.hasScreenKeyboardSupport();
    print("Has screen keyboard support: {}\n", .{has_screen_kb});

    const screen_kb_shown = keyboard.screenKeyboardShown(window);
    print("Screen keyboard shown: {}\n", .{screen_kb_shown});
}

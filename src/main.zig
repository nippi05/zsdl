const std = @import("std");
const zsdl = @import("zsdl");

pub fn main() !void {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try zsdl.video.Window.create(
        "Keyboard Test",
        600,
        600,
        .{ .resizable = true },
    );
    defer window.destroy();

    // Test basic keyboard availability
    std.debug.print("Has keyboard: {}\n", .{zsdl.keyboard.hasKeyboard()});

    // Get and print keyboard IDs
    if (zsdl.keyboard.hasKeyboard()) {
        const keyboards = try zsdl.keyboard.getKeyboards();
        std.debug.print("Available keyboards: {any}\n", .{keyboards});

        // Test getting keyboard name
        for (keyboards) |kb| {
            if (kb.getName()) |name| {
                std.debug.print("Keyboard name: {s}\n", .{name});
            }
        }
    }

    // Test keyboard focus
    if (zsdl.keyboard.getKeyboardFocus()) |focused_window| {
        std.debug.print("Keyboard focus window: {any}\n", .{focused_window});
    }

    // Get keyboard state
    var num_keys: c_int = undefined;
    const key_states = try zsdl.keyboard.getKeyboardState(&num_keys);
    std.debug.print("Number of keyboard keys: {}\n", .{num_keys});
    std.debug.print("Key states: {any}\n", .{key_states});

    // Test modifier state using new Keymod API
    const mod_state = zsdl.keyboard.Keymod.getState();
    std.debug.print("Current modifier state: {}\n", .{mod_state});

    // Test combining modifiers

    // Test text input
    try zsdl.keyboard.startTextInput(&window);
    std.debug.print("Text input active: {}\n", .{zsdl.keyboard.textInputActive(&window)});
    try zsdl.keyboard.stopTextInput(&window);

    // Test screen keyboard support
    std.debug.print("Has screen keyboard support: {}\n", .{zsdl.keyboard.hasScreenKeyboardSupport()});
    std.debug.print("Screen keyboard shown: {}\n", .{zsdl.keyboard.screenKeyboardShown(&window)});

    // Test key/scancode functions using new structured API
    const scancode = zsdl.keyboard.Scancode.a;
    const keycode = zsdl.keyboard.Keycode.a;

    std.debug.print("Scancode name for 'A': {s}\n", .{scancode.getName()});
    std.debug.print("Key name for 'A': {s}\n", .{keycode.getName()});

    // Test key conversion using new API
    const derived_key = scancode.getKey(.none, false);
    std.debug.print("Key from scancode: {}\n", .{derived_key});

    const modstate: zsdl.keyboard.Keymod = undefined;
    const derived_scancode = keycode.getScancode(modstate);
    std.debug.print("Scancode from key: {}\n", .{derived_scancode});

    // Test name-based conversions
    const sc_from_name = try zsdl.keyboard.Scancode.fromName("A");
    const key_from_name = try zsdl.keyboard.Keycode.fromName("A");
    std.debug.print("Scancode from name: {}\n", .{sc_from_name});
    std.debug.print("Key from name: {}\n", .{key_from_name});

    // Keep window open briefly to see results
    std.time.sleep(2 * std.time.ns_per_s);
}

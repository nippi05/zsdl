const std = @import("std");

const zsdl = @import("zsdl");
const mouse = zsdl.mouse;
const video = zsdl.video;

test "mouse functionality" {
    try zsdl.init(.everything);
    defer zsdl.quit();

    // Test basic mouse detection
    const has_mouse = mouse.hasMouse();
    std.debug.print("Has mouse: {}\n", .{has_mouse});

    // Test getting connected mice
    const mice = try mouse.getMice();
    std.debug.print("Connected mice: {any}\n", .{mice});

    // If we have mice, test getting mouse names
    if (mice.len > 0) {
        for (mice) |mouse_id| {
            const name = try mouse.getMouseNameForID(mouse_id);
            std.debug.print("Mouse {d} name: {s}\n", .{ mouse_id, name });
        }
    }

    // Create a simple window for mouse focus/state tests
    const window = try zsdl.video.Window.create("Mouse Test", 800, 600, .{});
    defer window.destroy();

    // Test mouse focus
    const focus_window = mouse.getMouseFocus();
    std.debug.print("Mouse focus: {any}\n", .{focus_window});

    // Test mouse state
    var x: f32 = undefined;
    var y: f32 = undefined;
    const state = mouse.getMouseState(&x, &y);
    std.debug.print("Mouse position: ({d}, {d})\n", .{ x, y });
    std.debug.print("Mouse buttons: left={}, middle={}, right={}, x1={}, x2={}\n", .{ state.left, state.middle, state.right, state.x1, state.x2 });

    // Test converting button flags to int and back
    const state_int = state.toInt();
    const state_back = mouse.MouseButtonFlags.fromInt(state_int);
    std.debug.print("Button flags conversion test: {any} -> {d} -> {any}\n", .{ state, state_int, state_back });

    // Test global mouse state
    var global_x: f32 = undefined;
    var global_y: f32 = undefined;
    const global_state = mouse.getGlobalMouseState(&global_x, &global_y);
    _ = global_state; // autofix
    std.debug.print("Global mouse position: ({d}, {d})\n", .{ global_x, global_y });

    // Test relative mouse state
    var rel_x: f32 = undefined;
    var rel_y: f32 = undefined;
    const rel_state = mouse.getRelativeMouseState(&rel_x, &rel_y);
    _ = rel_state; // autofix
    std.debug.print("Relative mouse movement: ({d}, {d})\n", .{ rel_x, rel_y });

    // Test cursor functionality
    std.debug.print("Cursor visible: {}\n", .{mouse.cursorVisible()});

    // Test system cursor creation (we'll use DEFAULT to avoid changing user's cursor)
    const cursor = try mouse.Cursor.createSystem(.default);
    defer cursor.destroy();

    // Test default cursor
    const default_cursor = try mouse.getDefaultCursor();
    _ = default_cursor; // Just testing we can get it

    // Get current cursor
    const current_cursor = mouse.getCursor();
    std.debug.print("Has cursor: {}\n", .{current_cursor != null});

    // The following functions would modify user's environment, so we'll just print info
    std.debug.print("\nFunctions that modify environment (not testing):\n", .{});
    std.debug.print("- mouse.warpMouseInWindow(window, x, y){any}\n", .{mouse.warpMouseInWindow(null, 0, 0)});
    std.debug.print("- mouse.warpMouseGlobal(x, y)\n", .{});
    std.debug.print("- mouse.setWindowRelativeMouseMode(window, enabled)\n", .{});
    std.debug.print("- mouse.captureMouse(enabled)\n", .{});
    std.debug.print("- mouse.showCursor()/hideCursor()\n", .{});
    std.debug.print("- cursor.set(){any}\n", .{cursor.set()});

    // Test for errors when the window is invalid - just making sure the API works
    {
        const invalid_window = video.Window{ .ptr = undefined };
        _ = invalid_window; // autofix
        const result = mouse.getWindowRelativeMouseMode(window);
        _ = result; // Just testing we can call the function
    }
}

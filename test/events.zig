const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const events = zsdl.events;
const c = zsdl.c;

test "EventType enum values match SDL constants" {
    // Test a sampling of event types across different categories
    try testing.expectEqual(@intFromEnum(events.EventType.first), c.SDL_EVENT_FIRST);
    try testing.expectEqual(@intFromEnum(events.EventType.quit), c.SDL_EVENT_QUIT);
    try testing.expectEqual(@intFromEnum(events.EventType.window_resized), c.SDL_EVENT_WINDOW_RESIZED);
    try testing.expectEqual(@intFromEnum(events.EventType.key_down), c.SDL_EVENT_KEY_DOWN);
    try testing.expectEqual(@intFromEnum(events.EventType.mouse_motion), c.SDL_EVENT_MOUSE_MOTION);
    try testing.expectEqual(@intFromEnum(events.EventType.joystick_axis_motion), c.SDL_EVENT_JOYSTICK_AXIS_MOTION);
    try testing.expectEqual(@intFromEnum(events.EventType.gamepad_button_down), c.SDL_EVENT_GAMEPAD_BUTTON_DOWN);
    try testing.expectEqual(@intFromEnum(events.EventType.finger_down), c.SDL_EVENT_FINGER_DOWN);
    try testing.expectEqual(@intFromEnum(events.EventType.clipboard_update), c.SDL_EVENT_CLIPBOARD_UPDATE);
    try testing.expectEqual(@intFromEnum(events.EventType.drop_file), c.SDL_EVENT_DROP_FILE);
    try testing.expectEqual(@intFromEnum(events.EventType.audio_device_added), c.SDL_EVENT_AUDIO_DEVICE_ADDED);
    try testing.expectEqual(@intFromEnum(events.EventType.sensor_update), c.SDL_EVENT_SENSOR_UPDATE);
    try testing.expectEqual(@intFromEnum(events.EventType.pen_down), c.SDL_EVENT_PEN_DOWN);
    try testing.expectEqual(@intFromEnum(events.EventType.camera_device_added), c.SDL_EVENT_CAMERA_DEVICE_ADDED);
    try testing.expectEqual(@intFromEnum(events.EventType.render_targets_reset), c.SDL_EVENT_RENDER_TARGETS_RESET);
    try testing.expectEqual(@intFromEnum(events.EventType.user), c.SDL_EVENT_USER);
    try testing.expectEqual(@intFromEnum(events.EventType.last), c.SDL_EVENT_LAST);
}

test "Event conversion to/from native format" {
    // Test a few representative event types

    // Quit event
    {
        var sdl_event: c.SDL_Event = std.mem.zeroes(c.SDL_Event);
        sdl_event.type = c.SDL_EVENT_QUIT;
        sdl_event.quit.timestamp = 12345;

        const zig_event = events.Event.fromNative(sdl_event);
        try testing.expectEqual(events.EventType.quit, @as(events.EventType, zig_event));
        try testing.expectEqual(@as(u64, 12345), zig_event.quit.timestamp);
    }

    // Window resized event
    {
        var sdl_event: c.SDL_Event = std.mem.zeroes(c.SDL_Event);
        sdl_event.type = c.SDL_EVENT_WINDOW_RESIZED;
        sdl_event.window.timestamp = 12345;
        sdl_event.window.windowID = 42;
        sdl_event.window.data1 = 800; // width
        sdl_event.window.data2 = 600; // height

        const zig_event = events.Event.fromNative(sdl_event);
        try testing.expectEqual(events.EventType.window_resized, @as(events.EventType, zig_event));
        try testing.expectEqual(@as(u64, 12345), zig_event.window_resized.timestamp);
        try testing.expectEqual(@as(c.SDL_WindowID, 42), zig_event.window_resized.windowID);
        try testing.expectEqual(@as(i32, 800), zig_event.window_resized.size.width);
        try testing.expectEqual(@as(i32, 600), zig_event.window_resized.size.height);
    }

    // Key down event
    {
        var sdl_event: c.SDL_Event = std.mem.zeroes(c.SDL_Event);
        sdl_event.type = c.SDL_EVENT_KEY_DOWN;
        sdl_event.key.timestamp = 12345;
        sdl_event.key.windowID = 42;
        sdl_event.key.which = 1;
        sdl_event.key.scancode = c.SDL_SCANCODE_A;
        sdl_event.key.key = c.SDLK_A;
        sdl_event.key.mod = c.SDL_KMOD_LSHIFT;
        sdl_event.key.repeat = false;

        const zig_event = events.Event.fromNative(sdl_event);
        try testing.expectEqual(events.EventType.key_down, @as(events.EventType, zig_event));
        try testing.expectEqual(@as(u64, 12345), zig_event.key_down.timestamp);
        try testing.expectEqual(@as(c.SDL_WindowID, 42), zig_event.key_down.windowID);
        try testing.expectEqual(@as(c.SDL_KeyboardID, 1), zig_event.key_down.which);
        try testing.expectEqual(c.SDLK_A, zig_event.key_down.keycode);
        try testing.expectEqual(c.SDL_KMOD_LSHIFT, zig_event.key_down.mod);
        try testing.expectEqual(false, zig_event.key_down.repeat);
    }

    // Mouse motion event
    {
        var sdl_event: c.SDL_Event = std.mem.zeroes(c.SDL_Event);
        sdl_event.type = c.SDL_EVENT_MOUSE_MOTION;
        sdl_event.motion.timestamp = 12345;
        sdl_event.motion.windowID = 42;
        sdl_event.motion.which = 1;
        sdl_event.motion.state = c.SDL_BUTTON_LMASK;
        sdl_event.motion.x = 100.0;
        sdl_event.motion.y = 200.0;
        sdl_event.motion.xrel = 5.0;
        sdl_event.motion.yrel = 10.0;

        const zig_event = events.Event.fromNative(sdl_event);
        try testing.expectEqual(events.EventType.mouse_motion, @as(events.EventType, zig_event));
        try testing.expectEqual(@as(u64, 12345), zig_event.mouse_motion.timestamp);
        try testing.expectEqual(@as(c.SDL_WindowID, 42), zig_event.mouse_motion.windowID);
        try testing.expectEqual(@as(c.SDL_MouseID, 1), zig_event.mouse_motion.which);
        try testing.expectEqual(c.SDL_BUTTON_LMASK, zig_event.mouse_motion.state);
        try testing.expectEqual(@as(f32, 100.0), zig_event.mouse_motion.x);
        try testing.expectEqual(@as(f32, 200.0), zig_event.mouse_motion.y);
        try testing.expectEqual(@as(f32, 5.0), zig_event.mouse_motion.xrel);
        try testing.expectEqual(@as(f32, 10.0), zig_event.mouse_motion.yrel);
    }

    // Gamepad button down event
    {
        var sdl_event: c.SDL_Event = std.mem.zeroes(c.SDL_Event);
        sdl_event.type = c.SDL_EVENT_GAMEPAD_BUTTON_DOWN;
        sdl_event.gbutton.timestamp = 12345;
        sdl_event.gbutton.which = 1;
        sdl_event.gbutton.button = c.SDL_GAMEPAD_BUTTON_LABEL_A;

        const zig_event = events.Event.fromNative(sdl_event);
        try testing.expectEqual(events.EventType.gamepad_button_down, @as(events.EventType, zig_event));
        try testing.expectEqual(@as(u64, 12345), zig_event.gamepad_button_down.timestamp);
        try testing.expectEqual(@as(c.SDL_JoystickID, 1), zig_event.gamepad_button_down.which);
        try testing.expectEqual(c.SDL_GAMEPAD_BUTTON_LABEL_A, zig_event.gamepad_button_down.button);
    }
}

test "Event polling basic functionality" {
    // This test is more of a smoke test since we can't easily simulate real events without a window
    // It just verifies the poll function returns without crashing

    // Poll for any pending events (likely none in a test environment)
    _ = events.pollEvent();

    // Pump the event loop
    events.pumpEvents();

    // These functions should at least not crash
    try testing.expect(!events.hasEvent(events.EventType.quit));
    try testing.expect(!events.hasEvents(events.EventType.first, events.EventType.last));

    // Test the event filter and watch functions
    const testFilterFunc = struct {
        fn filter(_: ?*anyopaque, _: [*c]c.SDL_Event) callconv(.C) bool {
            return true;
        }
    }.filter;

    // Set up an event filter
    events.setEventFilter(testFilterFunc, null);

    // Add and remove an event watch
    events.addEventWatch(testFilterFunc, null) catch |err| {
        // Some implementations might not support this, so don't fail the test
        std.debug.print("Note: addEventWatch failed with error: {}\n", .{err});
    };
    events.removeEventWatch(testFilterFunc, null);

    // Set event enabled state
    events.setEventEnabled(events.EventType.quit, true);
    try testing.expect(events.eventEnabled(events.EventType.quit));

    // Register user events (this should at least not crash)
    const registered_event = events.registerEvents(1);
    // This may return 0 if no events are available, which is fine for a test
    _ = registered_event;
}

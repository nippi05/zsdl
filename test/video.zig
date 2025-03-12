const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const video = zsdl.video;
const Window = video.Window;
const Size = zsdl.rect.Size;
const c = zsdl.c;

// Helper function to initialize SDL for tests
fn withSDL(comptime callback: fn () anyerror!void) !void {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();
    try callback();
}

// ===== Video Driver Tests =====

test "video drivers" {
    try withSDL(struct {
        fn f() !void {
            // Get number of drivers
            const num_drivers = video.getNumVideoDrivers();
            try testing.expect(num_drivers > 0);

            // Get first driver name
            if (num_drivers > 0) {
                const driver_name = video.getVideoDriver(0);
                try testing.expect(driver_name.len > 0);
            }

            // Get current driver
            const current_driver = video.getCurrentVideoDriver();
            try testing.expect(current_driver.len > 0);
        }
    }.f);
}

test "system theme" {
    try withSDL(struct {
        fn f() !void {
            const theme = video.getSystemTheme();
            // Just check we get a valid enum value
            try testing.expect(@intFromEnum(theme) <= @intFromEnum(video.SystemTheme.dark));
        }
    }.f);
}

// ===== Display Tests =====

test "display list" {
    try withSDL(struct {
        fn f() !void {
            const displays = try video.getDisplays();
            try testing.expect(displays.len > 0);
        }
    }.f);
}

test "primary display" {
    try withSDL(struct {
        fn f() !void {
            const primary = try video.getPrimaryDisplay();
            try testing.expect(primary.id != 0);

            // Display properties
            const name = primary.getName();
            try testing.expect(name.len > 0);

            // Bounds
            const bounds = try primary.getBounds();
            try testing.expect(bounds.w > 0);
            try testing.expect(bounds.h > 0);

            // Usable bounds
            const usable_bounds = try primary.getUsableBounds();
            try testing.expect(usable_bounds.w > 0);
            try testing.expect(usable_bounds.h > 0);

            // Content scale
            const scale = try primary.getContentScale();
            try testing.expect(scale > 0);

            // Properties
            const props = try primary.getProperties();
            try testing.expect(props != 0);

            // Orientation
            const orientation = primary.getCurrentOrientation();
            try testing.expect(@intFromEnum(orientation) <= @intFromEnum(video.DisplayOrientation.portrait_flipped));

            const natural_orientation = primary.getNaturalOrientation();
            try testing.expect(@intFromEnum(natural_orientation) <= @intFromEnum(video.DisplayOrientation.portrait_flipped));
        }
    }.f);
}

test "display modes" {
    try withSDL(struct {
        fn f() !void {
            const primary = try video.getPrimaryDisplay();

            // Get fullscreen modes
            const modes = try primary.getFullscreenDisplayModes();
            try testing.expect(modes.len > 0);

            // Get closest mode
            const size: Size = .{ .width = 800, .height = 600 };
            const closest_mode = try primary.getClosestFullscreenDisplayMode(@bitCast(size), 60.0, false);
            try testing.expect(closest_mode.w > 0);
            try testing.expect(closest_mode.h > 0);

            // Desktop mode
            const desktop_mode = try primary.getDesktopDisplayMode();
            try testing.expect(desktop_mode.w > 0);
            try testing.expect(desktop_mode.h > 0);

            // Current mode
            const current_mode = try primary.getCurrentDisplayMode();
            try testing.expect(current_mode.w > 0);
            try testing.expect(current_mode.h > 0);
        }
    }.f);
}

test "display coordinate functions" {
    try withSDL(struct {
        fn f() !void {
            // Get display for point
            const point: zsdl.rect.Point = .{ .x = 0, .y = 0 };
            const display_for_point = try video.Display.getForPoint(point);
            try testing.expect(display_for_point.id != 0);

            // Get display for rect
            const rect: zsdl.rect.Rect = .{ .x = 0, .y = 0, .w = 100, .h = 100 };
            const display_for_rect = try video.Display.getForRect(rect);
            try testing.expect(display_for_rect.id != 0);
        }
    }.f);
}

// ===== Window Tests =====

test "window creation" {
    try withSDL(struct {
        fn f() !void {
            // Basic window creation
            const window = try Window.create("Test Window", 100, 100, .{});
            defer window.destroy();

            // With properties
            const window_props = try Window.createWithProperties(.{
                .title = "Test Window Props\x00",
                .width = 200,
                .height = 200,
                .resizable = true,
            });
            defer window_props.destroy();

            // Check if flags are set correctly
            const flags = window_props.getFlags();
            try testing.expect(flags.resizable);
        }
    }.f);
}

test "window ID and lookup" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{});
            defer window.destroy();

            // Get ID
            const id = try window.getID();
            try testing.expect(id != 0);

            // Get window from ID
            const window2 = try Window.getFromID(id);
            try testing.expect(window2.ptr == window.ptr);
        }
    }.f);
}

test "window properties and metadata" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{});
            defer window.destroy();

            // Properties object
            const props = try window.getProperties();
            try testing.expect(props != 0);

            // Title
            try window.setTitle("New Title");
            const title = window.getTitle();
            try testing.expectEqualStrings("New Title", title);

            // Position
            const pos1: zsdl.rect.Point = .{ .x = 100, .y = 100 };
            try window.setPosition(pos1);
            const pos2 = try window.getPosition();
            // Can't test exact values because window manager might constrain position
            try testing.expect(pos2.x >= 0);
            try testing.expect(pos2.y >= 0);

            // Pixel format
            const pixel_format = try window.getPixelFormat();
            try testing.expect(@intFromEnum(pixel_format) != @intFromEnum(zsdl.pixels.PixelFormat.unknown));

            // Pixel density
            const density = try window.getPixelDensity();
            try testing.expect(density > 0);

            // Display scale
            const scale = try window.getDisplayScale();
            try testing.expect(scale > 0);

            // Display for window
            const display = try video.Display.getForWindow(window);
            try testing.expect(display.id != 0);
        }
    }.f);
}

test "window size functions" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{ .resizable = true });
            defer window.destroy();

            // Size
            const size1: Size = .{ .width = 200, .height = 200 };
            try window.setSize(size1);
            const size2 = try window.getSize();
            try testing.expectEqual(size1.width, size2.width);
            try testing.expectEqual(size1.height, size2.height);

            // Size in pixels
            const pixel_size = try window.getSizeInPixels();
            try testing.expect(pixel_size.width > 0);
            try testing.expect(pixel_size.height > 0);

            // Safe area
            const safe_area = try window.getSafeArea();
            try testing.expect(safe_area.w > 0);
            try testing.expect(safe_area.h > 0);

            // Aspect ratio
            const aspect: zsdl.rect.AspectRatio = .{ .min_aspect = 1.0, .max_aspect = 2.0 };
            try window.setAspectRatio(aspect);
            const current_aspect = try window.getAspectRatio();
            try testing.expectApproxEqAbs(aspect.min_aspect, current_aspect.min_aspect, 0.001);
            try testing.expectApproxEqAbs(aspect.max_aspect, current_aspect.max_aspect, 0.001);

            // Borders size
            const borders = try window.getBordersSize();
            _ = borders;
            // Just check the function works, values depend on window manager

            // Min/max size
            const min_size: Size = .{ .width = 50, .height = 50 };
            try window.setMinimumSize(min_size);
            const min = try window.getMinimumSize();
            try testing.expectEqual(min_size.width, min.width);
            try testing.expectEqual(min_size.height, min.height);

            const max_size: Size = .{ .width = 500, .height = 500 };
            try window.setMaximumSize(max_size);
            const max = try window.getMaximumSize();
            try testing.expectEqual(max_size.width, max.width);
            try testing.expectEqual(max_size.height, max.height);
        }
    }.f);
}

test "window state flags" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{});
            defer window.destroy();

            // Bordered
            try window.setBordered(false);
            var flags = window.getFlags();
            try testing.expect(flags.borderless);

            try window.setBordered(true);
            flags = window.getFlags();
            try testing.expect(!flags.borderless);

            // Resizable
            try window.setResizable(true);
            flags = window.getFlags();
            try testing.expect(flags.resizable);

            try window.setResizable(false);
            flags = window.getFlags();
            try testing.expect(!flags.resizable);

            // Always on top
            try window.setAlwaysOnTop(true);
            flags = window.getFlags();
            try testing.expect(flags.always_on_top);

            try window.setAlwaysOnTop(false);
            flags = window.getFlags();
            try testing.expect(!flags.always_on_top);

            // Hidden/shown
            try window.hide();
            flags = window.getFlags();
            try testing.expect(flags.hidden);

            try window.show();
            flags = window.getFlags();
            try testing.expect(!flags.hidden);

            // Focusable
            try window.setFocusable(false);
            flags = window.getFlags();
            try testing.expect(flags.not_focusable);

            try window.setFocusable(true);
            flags = window.getFlags();
            try testing.expect(!flags.not_focusable);
        }
    }.f);
}

test "window input handling" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{});
            defer window.destroy();

            // Mouse grab
            try window.setMouseGrab(true);
            try testing.expect(window.getMouseGrab());

            try window.setMouseGrab(false);
            try testing.expect(!window.getMouseGrab());

            // Keyboard grab
            try window.setKeyboardGrab(true);
            try testing.expect(window.getKeyboardGrab());

            try window.setKeyboardGrab(false);
            try testing.expect(!window.getKeyboardGrab());

            // Mouse rect
            const rect: zsdl.rect.Rect = .{ .x = 10, .y = 10, .w = 80, .h = 80 };
            try window.setMouseRect(rect);
            if (window.getMouseRect()) |mr| {
                try testing.expectEqual(rect.x, mr.x);
                try testing.expectEqual(rect.y, mr.y);
                try testing.expectEqual(rect.w, mr.w);
                try testing.expectEqual(rect.h, mr.h);
            }

            // Clear mouse rect
            try window.setMouseRect(null);
            try testing.expect(window.getMouseRect() == null);

            // Grab handling
            const grabbed = video.getGrabbedWindow();
            _ = grabbed;
            // This can be null if grab didn't work, so we just check the function runs
        }
    }.f);
}

test "window operations" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{ .resizable = true });
            defer window.destroy();

            // Window operations - just check they don't crash
            // Since these are usually asynchronous, we don't check the results
            try window.maximize();
            try window.sync();

            try window.minimize();
            try window.sync();

            try window.restore();
            try window.sync();

            try window.raise();

            try window.setFullscreen(true);
            try window.sync();

            try window.setFullscreen(false);
            try window.sync();

            // Fullscreen mode
            const fs_mode = try window.getFullscreenMode();
            _ = fs_mode;
            // Can be null if not in fullscreen mode

            // Opacity
            try window.setOpacity(0.8);
            const opacity = try window.getOpacity();
            try testing.expectApproxEqAbs(0.8, opacity, 0.1);
        }
    }.f);
}

test "window surface operations" {
    try withSDL(struct {
        fn f() !void {
            const window = try Window.create("Test Window", 100, 100, .{});
            defer window.destroy();

            if (!window.hasSurface()) {
                // Get surface
                const surface = try window.getSurface();
                _ = surface;
                try testing.expect(window.hasSurface());

                // Set VSync
                try window.setSurfaceVSync(1);
                const vsync = try window.getSurfaceVSync();
                try testing.expectEqual(1, vsync);

                // Update surface
                try window.updateSurface();

                // Update rects
                const rects = [_]zsdl.rect.Rect{
                    .{ .x = 0, .y = 0, .w = 50, .h = 50 },
                };
                try window.updateSurfaceRects(&rects);

                // Destroy surface
                try window.destroySurface();
                try testing.expect(!window.hasSurface());
            }
        }
    }.f);
}

test "parent-child window relations" {
    try withSDL(struct {
        fn f() !void {
            const parent = try Window.create("Parent Window", 100, 100, .{});
            defer parent.destroy();

            // Check parent is null initially

            // Create popup window
            const popup = try parent.createPopup(10, 10, .{ .width = 50, .height = 50 }, .{ .tooltip = true });
            defer popup.destroy();

            // Check parent reference is set
            const popup_parent = try popup.getParent();
            try testing.expect(popup_parent.ptr == parent.ptr);

            // Set modal state
            try popup.setModal(true);
            const flags = popup.getFlags();
            try testing.expect(flags.modal);
        }
    }.f);
}

test "window list" {
    try withSDL(struct {
        fn f() !void {
            // Create a couple windows
            const win1 = try Window.create("Window 1", 100, 100, .{});
            defer win1.destroy();

            const win2 = try Window.create("Window 2", 100, 100, .{});
            defer win2.destroy();

            // Get window list
            const windows = try video.getWindows();

            try testing.expect(windows.len >= 2);
        }
    }.f);
}

// ===== Screensaver Tests =====

test "screensaver functions" {
    try withSDL(struct {
        fn f() !void {
            // Get initial state
            const initial = video.screenSaverEnabled();

            // Disable
            try video.disableScreenSaver();
            try testing.expect(!video.screenSaverEnabled());

            // Enable
            try video.enableScreenSaver();
            try testing.expect(video.screenSaverEnabled());

            // Restore original state
            if (!initial) {
                try video.disableScreenSaver();
            }
        }
    }.f);
}

// ===== OpenGL Tests =====

test "GL attribute functions" {
    try withSDL(struct {
        fn f() !void {
            // Reset to defaults
            video.gl.resetAttributes();

            // Set an attribute
            try video.gl.setAttribute(.red_size, 8);

            // Get it back
            const value = try video.gl.getAttribute(.red_size);
            // Value might not be exactly 8, depending on the implementation
            try testing.expect(value >= 0);
        }
    }.f);
}

test "OpenGL context" {
    try withSDL(struct {
        fn f() !void {
            // Create OpenGL window
            const window = try Window.create("OpenGL Test", 100, 100, .{ .opengl = true });
            defer window.destroy();

            // Try to create context - might fail in headless environments
            _ = video.gl.GLContext.create(window) catch |err| {
                // Skip test if context creation fails
                std.debug.print("Skipping OpenGL context test: {}\n", .{err});
                return;
            };

            // We don't actually test more OpenGL functionality
            // as it depends heavily on the environment
        }
    }.f);
}

// ===== EGL Tests =====

test "EGL function signatures" {
    // Just check that the functions exist with correct types
    const GetProcAddressType = fn ([*:0]const u8) ?c.SDL_FunctionPointer;
    try testing.expect(@TypeOf(video.egl.getProcAddress) == GetProcAddressType);

    // Check that we can call it without crashing
    _ = video.egl.getProcAddress("eglGetProcAddress");

    // Set attribute callbacks (with null values)
    video.egl.setAttributeCallbacks(null, null, null, null);
}

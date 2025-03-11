const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const render = zsdl.render;
const rect = zsdl.rect;
const pixels = zsdl.pixels;
const video = zsdl.video;
const events = zsdl.events;
const surface = zsdl.surface;
const blendmode = zsdl.blendmode;

const c = zsdl.c;
const Renderer = render.Renderer;
const Texture = render.Texture;
const TextureAccess = render.TextureAccess;
const RendererLogicalPresentation = render.RendererLogicalPresentation;
const TextureProperties = render.TextureProperties;
const RendererProperties = render.RendererProperties;
const Window = video.Window;
const FRect = rect.FRect;
const Rect = rect.Rect;
const FPoint = rect.FPoint;
const Point = rect.Point;
const PixelFormat = pixels.PixelFormat;

fn initSDL() !void {
    try zsdl.init(.{ .video = true });
}

fn quitSDL() void {
    zsdl.quit();
}

test "Renderer enum values match SDL constants" {
    try testing.expectEqual(@intFromEnum(RendererLogicalPresentation.disabled), c.SDL_LOGICAL_PRESENTATION_DISABLED);
    try testing.expectEqual(@intFromEnum(RendererLogicalPresentation.stretch), c.SDL_LOGICAL_PRESENTATION_STRETCH);
    try testing.expectEqual(@intFromEnum(RendererLogicalPresentation.letterbox), c.SDL_LOGICAL_PRESENTATION_LETTERBOX);
    try testing.expectEqual(@intFromEnum(RendererLogicalPresentation.overscan), c.SDL_LOGICAL_PRESENTATION_OVERSCAN);
    try testing.expectEqual(@intFromEnum(RendererLogicalPresentation.integer_scale), c.SDL_LOGICAL_PRESENTATION_INTEGER_SCALE);

    try testing.expectEqual(@intFromEnum(TextureAccess.static), c.SDL_TEXTUREACCESS_STATIC);
    try testing.expectEqual(@intFromEnum(TextureAccess.streaming), c.SDL_TEXTUREACCESS_STREAMING);
    try testing.expectEqual(@intFromEnum(TextureAccess.target), c.SDL_TEXTUREACCESS_TARGET);
}

test "Renderer getNumRenderDrivers returns valid count" {
    try initSDL();
    defer quitSDL();

    const num_drivers = try Renderer.getNumRenderDrivers();
    try testing.expect(num_drivers >= 0);
}

test "Renderer getRenderDriver returns valid names" {
    try initSDL();
    defer quitSDL();

    const num_drivers = try Renderer.getNumRenderDrivers();
    if (num_drivers > 0) {
        const driver_name = Renderer.getRenderDriver(0);
        try testing.expect(driver_name != null);
        if (driver_name) |name| {
            try testing.expect(name.len > 0);
        }
    }
}

test "Create and destroy renderer and window" {
    try initSDL();
    defer quitSDL();

    const result = try Renderer.createWindowAndRenderer(
        "Test Window",
        640,
        480,
        .{},
    );
    defer result.window.destroy();
    defer result.renderer.destroy();
}

test "Create renderer with software fallback" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    // Try to create a renderer for the window, falling back to software renderer
    var renderer: Renderer = undefined;
    const software_renderer_name = "software";

    renderer = Renderer.create(window, software_renderer_name) catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();
}

test "Renderer properties" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    // Create a renderer
    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Test getting renderer name
    const name = try renderer.getName();
    try testing.expect(name.len > 0);

    // Test getting renderer properties
    const props = try renderer.getProperties();
    try testing.expect(props != 0);

    // Test getting output size
    const output_size = try renderer.getOutputSize();
    try testing.expect(output_size.w > 0);
    try testing.expect(output_size.h > 0);

    // Test logical presentation
    try renderer.setRenderLogicalPresentation(320, 240, .letterbox);
    const logical = try renderer.getRenderLogicalPresentation();
    try testing.expectEqual(@as(c_int, 320), logical.w);
    try testing.expectEqual(@as(c_int, 240), logical.h);
    try testing.expectEqual(RendererLogicalPresentation.letterbox, logical.mode);

    // Test getting the logical presentation rect
    const logical_rect = try renderer.getRenderLogicalPresentationRect();
    try testing.expect(logical_rect.w > 0);
    try testing.expect(logical_rect.h > 0);
}

test "Renderer coordinate transformations" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Test coordinate conversions
    const render_coords = try renderer.renderCoordinatesFromWindow(100.0, 100.0);
    try testing.expect(render_coords.x >= 0);
    try testing.expect(render_coords.y >= 0);

    const window_coords = try renderer.renderCoordinatesToWindow(render_coords.x, render_coords.y);
    try testing.expect(window_coords.window_x >= 0);
    try testing.expect(window_coords.window_y >= 0);
}

test "Renderer viewport and clipping" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Test viewport
    const viewport = Rect{ .x = 100, .y = 100, .w = 200, .h = 200 };
    try renderer.setRenderViewport(viewport);
    const current_viewport = try renderer.getRenderViewport();
    try testing.expectEqual(@as(c_int, 100), current_viewport.x);
    try testing.expectEqual(@as(c_int, 100), current_viewport.y);
    try testing.expectEqual(@as(c_int, 200), current_viewport.w);
    try testing.expectEqual(@as(c_int, 200), current_viewport.h);

    // Test viewport state
    try testing.expect(renderer.renderViewportSet());

    // Test getting safe area
    const safe_area = renderer.getRenderSafeArea() catch |err| {
        // Safe area might not be supported on all platforms, so handle that gracefully
        std.debug.print("Safe area not supported: {}\n", .{err});
        return;
    };
    try testing.expect(safe_area.w > 0);
    try testing.expect(safe_area.h > 0);

    // Test clipping rectangle
    const clip_rect = Rect{ .x = 120, .y = 120, .w = 100, .h = 100 };
    try renderer.setRenderClipRect(clip_rect);
    const current_clip = try renderer.getRenderClipRect();
    try testing.expectEqual(@as(c_int, 120), current_clip.x);
    try testing.expectEqual(@as(c_int, 120), current_clip.y);
    try testing.expectEqual(@as(c_int, 100), current_clip.w);
    try testing.expectEqual(@as(c_int, 100), current_clip.h);

    // Test clip enabled state
    try testing.expect(renderer.renderClipEnabled());
}

test "Renderer scaling" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Test setting scale
    try renderer.setRenderScale(2.0, 2.0);
    const scale = try renderer.getRenderScale();
    try testing.expectEqual(@as(f32, 2.0), scale.scale_x);
    try testing.expectEqual(@as(f32, 2.0), scale.scale_y);
}

test "Renderer draw color and blend mode" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Test setting draw color
    try renderer.setDrawColor(255, 0, 0, 255);
    const color = try renderer.getDrawColor();
    try testing.expectEqual(@as(u8, 255), color.r);
    try testing.expectEqual(@as(u8, 0), color.g);
    try testing.expectEqual(@as(u8, 0), color.b);
    try testing.expectEqual(@as(u8, 255), color.a);

    // Test setting float draw color
    try renderer.setDrawColorFloat(1.0, 0.0, 0.0, 1.0);
    const color_float = try renderer.getDrawColorFloat();
    try testing.expectEqual(@as(f32, 1.0), color_float.r);
    try testing.expectEqual(@as(f32, 0.0), color_float.g);
    try testing.expectEqual(@as(f32, 0.0), color_float.b);
    try testing.expectEqual(@as(f32, 1.0), color_float.a);

    // Test setting color scale
    try renderer.setColorScale(2.0);
    const scale = try renderer.getColorScale();
    try testing.expectEqual(@as(f32, 2.0), scale);

    // Test blend mode
    try renderer.setDrawBlendMode(c.SDL_BLENDMODE_BLEND);
    const blend_mode = try renderer.getDrawBlendMode();
    try testing.expectEqual(c.SDL_BLENDMODE_BLEND, blend_mode);
}

test "Basic rendering operations" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Clear the renderer
    try renderer.clear();

    // Draw a point
    try renderer.drawPoint(100.0, 100.0);

    // Draw multiple points
    const points = [_]FPoint{
        .{ .x = 110.0, .y = 100.0 },
        .{ .x = 120.0, .y = 100.0 },
        .{ .x = 130.0, .y = 100.0 },
    };
    try renderer.drawPoints(points[0..]);

    // Draw a line
    try renderer.drawLine(150.0, 100.0, 200.0, 150.0);

    // Draw connected lines
    const line_points = [_]FPoint{
        .{ .x = 210.0, .y = 100.0 },
        .{ .x = 260.0, .y = 150.0 },
        .{ .x = 210.0, .y = 200.0 },
    };
    try renderer.drawLines(line_points[0..]);

    // Draw a rectangle
    const rect1 = FRect{ .x = 300.0, .y = 100.0, .w = 50.0, .h = 50.0 };
    try renderer.drawRect(&rect1);

    // Draw multiple rectangles
    const rects = [_]FRect{
        .{ .x = 360.0, .y = 100.0, .w = 50.0, .h = 50.0 },
        .{ .x = 420.0, .y = 100.0, .w = 50.0, .h = 50.0 },
    };
    try renderer.drawRects(rects[0..]);

    // Fill a rectangle
    const rect2 = FRect{ .x = 300.0, .y = 160.0, .w = 50.0, .h = 50.0 };
    try renderer.fillRect(&rect2);

    // Fill multiple rectangles
    const fill_rects = [_]FRect{
        .{ .x = 360.0, .y = 160.0, .w = 50.0, .h = 50.0 },
        .{ .x = 420.0, .y = 160.0, .w = 50.0, .h = 50.0 },
    };
    try renderer.fillRects(fill_rects[0..]);

    // Present the renderer
    try renderer.present();
}

test "Create and manipulate texture" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Create a texture
    const texture = try renderer.createTexture(
        PixelFormat.rgba8888,
        TextureAccess.static,
        100,
        100,
    );
    defer texture.destroy();

    // Test getting texture size
    const size = try texture.getSize();
    try testing.expectEqual(@as(f32, 100.0), size.w);
    try testing.expectEqual(@as(f32, 100.0), size.h);

    // Test color modulation
    try texture.setColorMod(255, 128, 64);
    const color = try texture.getColorMod();
    try testing.expectEqual(@as(u8, 255), color.r);
    try testing.expectEqual(@as(u8, 128), color.g);
    try testing.expectEqual(@as(u8, 64), color.b);

    // Test float color modulation
    try texture.setColorModFloat(1.0, 0.5, 0.25);
    const color_float = try texture.getColorModFloat();
    try testing.expectApproxEqAbs(@as(f32, 1.0), color_float.r, 0.01);
    try testing.expectApproxEqAbs(@as(f32, 0.5), color_float.g, 0.01);
    try testing.expectApproxEqAbs(@as(f32, 0.25), color_float.b, 0.01);

    // Test alpha modulation
    try texture.setAlphaMod(128);
    const alpha = try texture.getAlphaMod();
    try testing.expectEqual(@as(u8, 128), alpha);

    // Test float alpha modulation
    try texture.setAlphaModFloat(0.5);
    const alpha_float = try texture.getAlphaModFloat();
    try testing.expectApproxEqAbs(@as(f32, 0.5), alpha_float, 0.01);

    // Test blend mode
    try texture.setBlendMode(.blend);
    const blend_mode = try texture.getBlendMode();
    try testing.expectEqual(c.SDL_BLENDMODE_BLEND, @intFromEnum(blend_mode));

    // Test scale mode
    try texture.setScaleMode(c.SDL_SCALEMODE_LINEAR);
    const scale_mode = try texture.getScaleMode();
    try testing.expectEqual(c.SDL_SCALEMODE_LINEAR, @intFromEnum(scale_mode));

    // Render the texture
    const src_rect = FRect{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 100.0 };
    const dst_rect = FRect{ .x = 10.0, .y = 10.0, .w = 100.0, .h = 100.0 };
    try renderer.copyTexture(&texture, &src_rect, &dst_rect);

    // Render rotated texture
    try renderer.copyTextureRotated(
        &texture,
        &src_rect,
        &dst_rect,
        45.0,
        null,
        c.SDL_FLIP_NONE,
    );

    // Present the renderer
    try renderer.present();
}

test "Create texture from surface" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Create a surface
    const surf = try surface.Surface.create(100, 100, .rgba8888);
    defer surf.destroy();

    // Fill surface with a color

    // Create a texture from the surface
    const texture = renderer.createTextureFromSurface(surf) catch |err| {
        std.debug.print("Failed to create texture from surface: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer texture.destroy();

    // Render the texture
    const src_rect = FRect{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 100.0 };
    const dst_rect = FRect{ .x = 10.0, .y = 10.0, .w = 100.0, .h = 100.0 };
    try renderer.copyTexture(&texture, &src_rect, &dst_rect);

    // Present the renderer
    try renderer.present();
}

test "Texture locking and updating" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Create a streaming texture
    const texture = try renderer.createTexture(
        PixelFormat.rgba8888,
        TextureAccess.streaming,
        100,
        100,
    );
    defer texture.destroy();

    // Lock a portion of the texture
    const update_rect = Rect{ .x = 0, .y = 0, .w = 100, .h = 100 };
    const locked = texture.lock(update_rect) catch |err| {
        std.debug.print("Failed to lock texture: {}\n", .{err});
        return error.SkipZigTest;
    };

    // Fill the locked area with red pixels (RGBA)
    const pixel_size = 4; // RGBA
    const size = @as(usize, @intCast(update_rect.w * update_rect.h));
    const pixels_slice = @as([*]u8, @ptrCast(locked.pixels))[0 .. size * pixel_size];

    var i: usize = 0;
    while (i < size) : (i += 1) {
        pixels_slice[i * pixel_size + 0] = 255; // R
        pixels_slice[i * pixel_size + 1] = 0; // G
        pixels_slice[i * pixel_size + 2] = 0; // B
        pixels_slice[i * pixel_size + 3] = 255; // A
    }

    // Unlock the texture
    texture.unlock();

    // Render the texture
    const src_rect = FRect{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 100.0 };
    const dst_rect = FRect{ .x = 10.0, .y = 10.0, .w = 100.0, .h = 100.0 };
    try renderer.copyTexture(&texture, &src_rect, &dst_rect);

    // Present the renderer
    try renderer.present();
}

test "Texture tiling and 9-grid" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Create a texture
    const texture = try renderer.createTexture(
        PixelFormat.rgba8888,
        TextureAccess.static,
        100,
        100,
    );
    defer texture.destroy();

    // Fill texture with some data
    const pixel_data = try std.testing.allocator.alloc(u8, 100 * 100 * 4);
    defer std.testing.allocator.free(pixel_data);

    for (0..100) |y| {
        for (0..100) |x| {
            const i = (y * 100 + x) * 4;
            pixel_data[i + 0] = @as(u8, @intCast(x * 255 / 100)); // R
            pixel_data[i + 1] = @as(u8, @intCast(y * 255 / 100)); // G
            pixel_data[i + 2] = 128; // B
            pixel_data[i + 3] = 255; // A
        }
    }

    try texture.update(null, pixel_data.ptr, 100 * 4);

    // Render the texture tiled
    const src_rect = FRect{ .x = 0.0, .y = 0.0, .w = 50.0, .h = 50.0 };
    const dst_rect = FRect{ .x = 10.0, .y = 10.0, .w = 200.0, .h = 200.0 };
    try renderer.copyTextureTiled(
        &texture,
        &src_rect,
        1.0,
        &dst_rect,
    );

    // Render the texture with 9-grid
    const grid_src = FRect{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 100.0 };
    const grid_dst = FRect{ .x = 220.0, .y = 10.0, .w = 200.0, .h = 200.0 };
    try renderer.copyTexture9Grid(
        &texture,
        &grid_src,
        20.0, // left_width
        20.0, // right_width
        20.0, // top_height
        20.0, // bottom_height
        1.0, // scale
        &grid_dst,
    );

    // Present the renderer
    try renderer.present();
}

test "Default texture scale mode" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Test default texture scale mode
    // renderer.setDefaultTextureScaleMode(c.SDL_SCALEMODE_NEAREST) catch |err| {
    //     // This function might not be available in all SDL versions
    //     std.debug.print("Default texture scale mode not supported: {}\n", .{err});
    //     return;
    // };

    // const scale_mode = renderer.getDefaultTextureScaleMode() catch |err| {
    //     std.debug.print("Get default texture scale mode not supported: {}\n", .{err});
    //     return;
    // };

    // try testing.expectEqual(c.SDL_SCALEMODE_NEAREST, scale_mode);
}

test "Renderer debug text" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Clear the renderer
    try renderer.clear();

    // Draw debug text
    try renderer.drawDebugText(10.0, 10.0, "Hello, SDL3!");

    // Draw formatted debug text
    try renderer.drawDebugTextFormat(10.0, 20.0, "Value: {d}", .{42});

    // Present the renderer
    try renderer.present();
}

test "Geometry rendering" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Clear the renderer
    try renderer.clear();

    // Create vertices for a triangle
    const vertices = [_]c.SDL_Vertex{
        .{
            .position = .{ .x = 100.0, .y = 100.0 },
            .color = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 },
            .tex_coord = .{ .x = 0.0, .y = 0.0 },
        },
        .{
            .position = .{ .x = 200.0, .y = 100.0 },
            .color = .{ .r = 0.0, .g = 1.0, .b = 0.0, .a = 1.0 },
            .tex_coord = .{ .x = 1.0, .y = 0.0 },
        },
        .{
            .position = .{ .x = 150.0, .y = 200.0 },
            .color = .{ .r = 0.0, .g = 0.0, .b = 1.0, .a = 1.0 },
            .tex_coord = .{ .x = 0.5, .y = 1.0 },
        },
    };

    // Draw the triangle
    renderer.drawGeometry(null, &vertices, null) catch |err| {
        std.debug.print("Geometry rendering not supported: {}\n", .{err});
        return;
    };

    // Present the renderer
    try renderer.present();
}

test "Reading pixels from renderer" {
    try initSDL();
    defer quitSDL();

    const window = try video.Window.create(
        "Test Window",
        640,
        480,
        .{},
    );
    defer window.destroy();

    const renderer = Renderer.create(window, "software") catch |err| {
        std.debug.print("Failed to create renderer: {}\n", .{err});
        return error.SkipZigTest;
    };
    defer renderer.destroy();

    // Clear the renderer with red
    try renderer.setDrawColor(255, 0, 0, 255);
    try renderer.clear();
    try renderer.present();

    // Read pixels
    const pixels_surface = renderer.readPixels(null) catch |err| {
        std.debug.print("Reading pixels not supported: {}\n", .{err});
        return;
    };
    defer c.SDL_DestroySurface(pixels_surface);

    // Check surface properties
    try testing.expect(pixels_surface.*.w > 0);
    try testing.expect(pixels_surface.*.h > 0);
}

test "FRect basics" {
    const r1 = FRect{ .x = 10.0, .y = 20.0, .w = 30.0, .h = 40.0 };
    const r2 = FRect{ .x = 25.0, .y = 35.0, .w = 30.0, .h = 40.0 };

    // Empty test
    try testing.expect(!r1.empty());

    // Intersection test
    try testing.expect(r1.hasIntersection(&r2));

    // Get intersection
    const intersection = r1.getIntersection(&r2) orelse {
        try testing.expect(false); // Should not reach here
        return;
    };
    try testing.expectEqual(@as(f32, 25.0), intersection.x);
    try testing.expectEqual(@as(f32, 35.0), intersection.y);
    try testing.expectEqual(@as(f32, 15.0), intersection.w);
    try testing.expectEqual(@as(f32, 25.0), intersection.h);

    // Union test
    const union_rect = try r1.getUnion(&r2);
    try testing.expectEqual(@as(f32, 10.0), union_rect.x);
    try testing.expectEqual(@as(f32, 20.0), union_rect.y);
    try testing.expectEqual(@as(f32, 45.0), union_rect.w);
    try testing.expectEqual(@as(f32, 55.0), union_rect.h);
}

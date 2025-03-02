const std = @import("std");

const c = @import("c.zig").c;
const internal = @import("internal.zig");
const errify = internal.errify;
const pixelsl = @import("pixels.zig");
const PixelFormat = pixelsl.PixelFormat;
const rectl = @import("rect.zig");
const FRect = rectl.FRect;
const Rect = rectl.Rect;
const FPoint = rectl.FPoint;
const Surface = @import("surface.zig").Surface;
const video = @import("video.zig");
const Window = video.Window;
const WindowFlags = video.WindowFlags;

pub const RendererLogicalPresentation = enum(u32) {
    disabled = c.SDL_LOGICAL_PRESENTATION_DISABLED,
    stretch = c.SDL_LOGICAL_PRESENTATION_STRETCH,
    letterbox = c.SDL_LOGICAL_PRESENTATION_LETTERBOX,
    overscan = c.SDL_LOGICAL_PRESENTATION_OVERSCAN,
    integer_scale = c.SDL_LOGICAL_PRESENTATION_INTEGER_SCALE,
};

pub const TextureAccess = enum(u32) {
    static = c.SDL_TEXTUREACCESS_STATIC,
    streaming = c.SDL_TEXTUREACCESS_STREAMING,
    target = c.SDL_TEXTUREACCESS_TARGET,
};

pub const TextureProperties = struct {
    colorspace: ?c.SDL_Colorspace = null,
    format: ?c.SDL_PixelFormat = null,
    access: ?c.SDL_TextureAccess = null,
    width: ?c_int = null,
    height: ?c_int = null,
    sdr_white_point: ?f32 = null,
    hdr_headroom: ?f32 = null,
    d3d11_texture: ?*anyopaque = null,
    d3d11_texture_u: ?*anyopaque = null,
    d3d11_texture_v: ?*anyopaque = null,
    d3d12_texture: ?*anyopaque = null,
    d3d12_texture_u: ?*anyopaque = null,
    d3d12_texture_v: ?*anyopaque = null,
    metal_pixelbuffer: ?*anyopaque = null,
    opengl_texture: ?c_uint = null,
    opengl_texture_uv: ?c_uint = null,
    opengl_texture_u: ?c_uint = null,
    opengl_texture_v: ?c_uint = null,
    vulkan_texture: ?c_uint = null,

    inline fn apply(self: TextureProperties, props: c.SDL_PropertiesID) void {
        if (self.colorspace) |cs| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_COLORSPACE_NUMBER, @intFromEnum(cs));
        if (self.format) |f| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_FORMAT_NUMBER, @intFromEnum(f));
        if (self.access) |a| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER, @intFromEnum(a));
        if (self.width) |w| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER, w);
        if (self.height) |h| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER, h);
        if (self.sdr_white_point) |swp| _ = c.SDL_SetFloatProperty(props, c.SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT, swp);
        if (self.hdr_headroom) |hdr| _ = c.SDL_SetFloatProperty(props, c.SDL_PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT, hdr);
        if (self.d3d11_texture) |t| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER, t);
        if (self.d3d11_texture_u) |t| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER, t);
        if (self.d3d11_texture_v) |t| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER, t);
        if (self.d3d12_texture) |t| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER, t);
        if (self.d3d12_texture_u) |t| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER, t);
        if (self.d3d12_texture_v) |t| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER, t);
        if (self.metal_pixelbuffer) |pb| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER, pb);
        if (self.opengl_texture) |t| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER, t);
        if (self.opengl_texture_uv) |t| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER, t);
        if (self.opengl_texture_u) |t| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER, t);
        if (self.opengl_texture_v) |t| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER, t);
        if (self.vulkan_texture) |t| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER, t);
    }
};

pub const RendererProperties = struct {
    name: ?[*:0]const u8 = null,
    window: ?*Window = null,
    surface: ?*c.SDL_Surface = null,
    output_colorspace: ?c.SDL_Colorspace = null,
    present_vsync: ?c_int = null,
    vulkan_instance: ?*anyopaque = null,
    vulkan_surface: ?c_uint = null,
    vulkan_physical_device: ?*anyopaque = null,
    vulkan_device: ?*anyopaque = null,
    vulkan_graphics_queue_family_index: ?c_int = null,
    vulkan_present_queue_family_index: ?c_int = null,

    inline fn apply(self: RendererProperties, props: c.SDL_PropertiesID) void {
        if (self.name) |n| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_RENDERER_CREATE_NAME_STRING, n);
        if (self.window) |w| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_RENDERER_CREATE_WINDOW_POINTER, w.ptr);
        if (self.surface) |s| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_RENDERER_CREATE_SURFACE_POINTER, s);
        if (self.output_colorspace) |cs| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER, @intFromEnum(cs));
        if (self.present_vsync) |vs| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER, vs);
        if (self.vulkan_instance) |vi| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER, vi);
        if (self.vulkan_surface) |vs| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER, vs);
        if (self.vulkan_physical_device) |vpd| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER, vpd);
        if (self.vulkan_device) |vd| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER, vd);
        if (self.vulkan_graphics_queue_family_index) |vgqfi| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER, vgqfi);
        if (self.vulkan_present_queue_family_index) |vpqfi| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER, vpqfi);
    }
};

pub const Renderer = struct {
    ptr: *c.SDL_Renderer,

    /// Get the number of 2D rendering drivers available for the current display.
    pub inline fn getNumRenderDrivers() !c_int {
        return errify(c.SDL_GetNumRenderDrivers());
    }

    /// Get the name of a built in 2D rendering driver.
    pub inline fn getRenderDriver(index: c_int) ?[]const u8 {
        return std.mem.span(try errify(c.SDL_GetRenderDriver(index)));
    }

    /// Create a window and default renderer.
    pub inline fn createWindowAndRenderer(
        title: [*:0]const u8,
        width: c_int,
        height: c_int,
        window_flags: WindowFlags,
    ) !struct { window: Window, renderer: Renderer } {
        var window_ptr: ?*c.SDL_Window = null;
        var renderer_ptr: ?*c.SDL_Renderer = null;
        try errify(c.SDL_CreateWindowAndRenderer(
            title,
            width,
            height,
            window_flags.toInt(),
            &window_ptr,
            &renderer_ptr,
        ));
        return .{
            .window = .{ .ptr = window_ptr.? },
            .renderer = .{ .ptr = renderer_ptr.? },
        };
    }

    /// Create a 2D rendering context for a window.
    pub inline fn create(window: Window, name: []const u8) !Renderer {
        const renderer = try errify(c.SDL_CreateRenderer(window.ptr, name));
        return Renderer{
            .ptr = renderer,
        };
    }

    /// Create a renderer with the specified properties.
    pub inline fn createWithProperties(props: RendererProperties) !Renderer {
        const properties = c.SDL_CreateProperties();
        defer c.SDL_DestroyProperties(properties);
        props.apply(properties);
        const renderer = try errify(c.SDL_CreateRendererWithProperties(properties));
        return Renderer{
            .ptr = renderer,
        };
    }

    /// Create a 2D software rendering context for a surface.
    pub inline fn createSoftwareRenderer(surface: *c.SDL_Surface) !Renderer {
        const renderer = try errify(c.SDL_CreateSoftwareRenderer(surface));
        return Renderer{
            .ptr = renderer,
        };
    }

    /// Set a texture as the current rendering target.
    pub inline fn setRenderTarget(self: *const Renderer, texture: Texture) !void {
        try errify(c.SDL_SetRenderTarget(self.ptr, texture.ptr));
    }

    /// Get the current render target.
    pub inline fn getRenderTarget(self: *const Renderer) Texture {
        const texture = c.SDL_GetRenderTarget(self.ptr);
        return Texture{
            .ptr = texture,
        };
    }

    /// Set device independent resolution and presentation mode for rendering.
    pub inline fn setRenderLogicalPresentation(self: *const Renderer, w: c_int, h: c_int, mode: RendererLogicalPresentation) !void {
        try errify(c.SDL_SetRenderLogicalPresentation(self.ptr, w, h, @intFromEnum(mode)));
    }

    /// Get device independent resolution and presentation mode for rendering.
    pub inline fn getRenderLogicalPresentation(self: *const Renderer) !struct { w: c_int, h: c_int, mode: RendererLogicalPresentation } {
        var w: c_int = undefined;
        var h: c_int = undefined;
        var mode: c.SDL_RendererLogicalPresentation = undefined;
        try errify(c.SDL_GetRenderLogicalPresentation(self.ptr, &w, &h, &mode));
        return .{ .w = w, .h = h, .mode = @enumFromInt(mode) };
    }

    /// Get the final presentation rectangle for rendering.
    pub inline fn getRenderLogicalPresentationRect(self: *const Renderer) !FRect {
        var rect: FRect = undefined;
        try errify(c.SDL_GetRenderLogicalPresentationRect(self.ptr, &rect));
        return rect;
    }

    /// Get a point in render coordinates when given a point in window coordinates.
    pub inline fn renderCoordinatesFromWindow(self: *const Renderer, window_x: f32, window_y: f32) !struct { x: f32, y: f32 } {
        var x: f32 = undefined;
        var y: f32 = undefined;
        try errify(c.SDL_RenderCoordinatesFromWindow(self.ptr, window_x, window_y, &x, &y));
        return .{ .x = x, .y = y };
    }

    /// Get a point in window coordinates when given a point in render coordinates.
    pub inline fn renderCoordinatesToWindow(self: *const Renderer, x: f32, y: f32) !struct { window_x: f32, window_y: f32 } {
        var window_x: f32 = undefined;
        var window_y: f32 = undefined;
        try errify(c.SDL_RenderCoordinatesToWindow(self.ptr, x, y, &window_x, &window_y));
        return .{ .window_x = window_x, .window_y = window_y };
    }

    /// Convert the coordinates in an event to render coordinates.
    pub inline fn convertEventToRenderCoordinates(self: *const Renderer, event: *c.SDL_Event) !void {
        try errify(c.SDL_ConvertEventToRenderCoordinates(self.ptr, event));
    }

    /// Set the drawing area for rendering on the current target.
    pub inline fn setRenderViewport(self: *const Renderer, rect: ?*const c.SDL_Rect) !void {
        try errify(c.SDL_SetRenderViewport(self.ptr, rect));
    }

    /// Get the drawing area for the current target.
    pub inline fn getRenderViewport(self: *const Renderer) !c.SDL_Rect {
        var rect: c.SDL_Rect = undefined;
        try errify(c.SDL_GetRenderViewport(self.ptr, &rect));
        return rect;
    }

    /// Return whether an explicit rectangle was set as the viewport.
    pub inline fn renderViewportSet(self: *const Renderer) bool {
        return c.SDL_RenderViewportSet(self.ptr);
    }

    /// Get the safe area for rendering within the current viewport.
    pub inline fn getRenderSafeArea(self: *const Renderer) !Rect {
        var rect: c.SDL_Rect = undefined;
        try errify(c.SDL_GetRenderSafeArea(self.ptr, &rect));
        return rect;
    }

    /// Set the clip rectangle for rendering on the specified target.
    pub inline fn setRenderClipRect(self: *const Renderer, rect: Rect) !void {
        try errify(c.SDL_SetRenderClipRect(self.ptr, rect));
    }

    /// Get the clip rectangle for the current target.
    pub inline fn getRenderClipRect(self: *const Renderer) !Rect {
        var rect: Rect = undefined;
        try errify(c.SDL_GetRenderClipRect(self.ptr, &rect));
        return rect;
    }

    /// Get whether clipping is enabled on the given renderer.
    pub inline fn renderClipEnabled(self: *const Renderer) !bool {
        return errify(c.SDL_RenderClipEnabled(self.ptr));
    }

    /// Set the drawing scale for rendering on the current target.
    pub inline fn setRenderScale(self: *const Renderer, scale_x: f32, scale_y: f32) !void {
        try errify(c.SDL_SetRenderScale(self.ptr, scale_x, scale_y));
    }

    /// Get the drawing scale for the current target.
    pub inline fn getRenderScale(self: *const Renderer) !struct { scale_x: f32, scale_y: f32 } {
        var scale_x: f32 = undefined;
        var scale_y: f32 = undefined;
        try errify(c.SDL_GetRenderScale(self.ptr, &scale_x, &scale_y));
        return .{ .scale_x = scale_x, .scale_y = scale_y };
    }

    /// Create a texture for a rendering context.
    pub inline fn createTexture(self: *const Renderer, format: PixelFormat, access: TextureAccess, w: usize, h: usize) !Texture {
        return .{
            .ptr = try errify(c.SDL_CreateTexture(
                self.ptr,
                @intFromEnum(format),
                @intFromEnum(access),
                w,
                h,
            )),
        };
    }

    /// Create a texture from an existing surface.
    pub inline fn createTextureFromSurface(self: *const Renderer, surface: *Surface) !Texture {
        return .{
            .ptr = try errify(c.SDL_CreateTextureFromSurface(self.ptr, surface.ptr)),
        };
    }

    /// Create a texture with specified properties.
    pub inline fn createTextureWithProperties(self: *const Renderer, props: TextureProperties) !Texture {
        const properties = c.SDL_CreateProperties();
        defer c.SDL_DestroyProperties(properties);
        props.apply(properties);
        const texture = c.SDL_CreateTextureWithProperties(self.ptr, properties);
        try errify(texture != null);
        return Texture{ .ptr = texture.? };
    }

    /// Get the renderer associated with a window.
    pub inline fn getFromWindow(window: *const Window) !Renderer {
        const renderer = try errify(c.SDL_GetRenderer(window.ptr));
        return Renderer{ .ptr = renderer };
    }

    /// Get the window associated with a renderer.
    pub inline fn getWindow(self: *const Renderer) !Window {
        const window = try errify(c.SDL_GetRenderWindow(self.ptr));
        return Window{ .ptr = window };
    }

    /// Get the name of a renderer.
    pub inline fn getName(self: *const Renderer) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetRendererName(self.ptr)));
    }

    /// Get the properties associated with a renderer.
    pub inline fn getProperties(self: *const Renderer) !c.SDL_PropertiesID {
        return try errify(c.SDL_GetRendererProperties(self.ptr));
    }

    /// Get the output size in pixels of a rendering context.
    pub inline fn getOutputSize(self: *const Renderer) !struct { w: c_int, h: c_int } {
        var w: c_int = undefined;
        var h: c_int = undefined;
        try errify(c.SDL_GetRenderOutputSize(self.ptr, &w, &h));
        return .{ .w = w, .h = h };
    }

    /// Get the current output size in pixels of a rendering context.
    pub inline fn getCurrentOutputSize(self: *const Renderer) !struct { w: c_int, h: c_int } {
        var w: c_int = undefined;
        var h: c_int = undefined;
        try errify(c.SDL_GetCurrentRenderOutputSize(self.ptr, &w, &h));
        return .{ .w = w, .h = h };
    }

    /// Set the color used for drawing operations.
    pub inline fn setDrawColor(self: *const Renderer, r: u8, g: u8, b: u8, a: u8) !void {
        try errify(c.SDL_SetRenderDrawColor(self.ptr, r, g, b, a));
    }

    /// Set the color used for drawing operations (Rect, Line and Clear).
    pub inline fn setDrawColorFloat(self: *const Renderer, r: f32, g: f32, b: f32, a: f32) !void {
        try errify(c.SDL_SetRenderDrawColorFloat(self.ptr, r, g, b, a));
    }

    /// Get the color used for drawing operations.
    pub inline fn getDrawColor(self: *const Renderer) !struct { r: u8, g: u8, b: u8, a: u8 } {
        var r: u8 = undefined;
        var g: u8 = undefined;
        var b: u8 = undefined;
        var a: u8 = undefined;
        try errify(c.SDL_GetRenderDrawColor(self.ptr, &r, &g, &b, &a));
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// Get the color used for drawing operations (Rect, Line and Clear).
    pub inline fn getDrawColorFloat(self: *const Renderer) !struct { r: f32, g: f32, b: f32, a: f32 } {
        var r: f32 = undefined;
        var g: f32 = undefined;
        var b: f32 = undefined;
        var a: f32 = undefined;
        try errify(c.SDL_GetRenderDrawColorFloat(self.ptr, &r, &g, &b, &a));
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// Set the color scale used for render operations.
    pub inline fn setColorScale(self: *const Renderer, scale: f32) !void {
        try errify(c.SDL_SetRenderColorScale(self.ptr, scale));
    }

    /// Get the color scale used for render operations.
    pub inline fn getColorScale(self: *const Renderer) !f32 {
        var scale: f32 = undefined;
        try errify(c.SDL_GetRenderColorScale(self.ptr, &scale));
        return scale;
    }

    /// Set the blend mode used for drawing operations (Fill and Line).
    pub inline fn setDrawBlendMode(self: *const Renderer, blend_mode: c.SDL_BlendMode) !void {
        try errify(c.SDL_SetRenderDrawBlendMode(self.ptr, blend_mode));
    }

    /// Get the blend mode used for drawing operations.
    pub inline fn getDrawBlendMode(self: *const Renderer) !c.SDL_BlendMode {
        var blend_mode: c.SDL_BlendMode = undefined;
        try errify(c.SDL_GetRenderDrawBlendMode(self.ptr, &blend_mode));
        return blend_mode;
    }

    /// Clear the current rendering target with the drawing color.
    pub inline fn clear(self: *const Renderer) !void {
        try errify(c.SDL_RenderClear(self.ptr));
    }

    /// Draw a point on the current rendering target at subpixel precision.
    pub inline fn drawPoint(self: *const Renderer, x: f32, y: f32) !void {
        try errify(c.SDL_RenderPoint(self.ptr, x, y));
    }

    /// Draw multiple points on the current rendering target at subpixel precision.
    pub inline fn drawPoints(self: *const Renderer, points: []const FPoint) !void {
        try errify(c.SDL_RenderPoints(self.ptr, @ptrCast(points.ptr), @intCast(points.len)));
    }

    /// Draw a line on the current rendering target at subpixel precision.
    pub inline fn drawLine(self: *const Renderer, x1: f32, y1: f32, x2: f32, y2: f32) !void {
        try errify(c.SDL_RenderLine(self.ptr, x1, y1, x2, y2));
    }

    /// Draw a series of connected lines on the current rendering target at subpixel precision.
    pub inline fn drawLines(self: *const Renderer, points: []const FPoint) !void {
        try errify(c.SDL_RenderLines(self.ptr, points.ptr, @intCast(points.len)));
    }

    /// Draw a rectangle on the current rendering target at subpixel precision.
    pub inline fn drawRect(self: *const Renderer, rect: ?*const FRect) !void {
        try errify(c.SDL_RenderRect(self.ptr, rect));
    }

    /// Draw some number of rectangles on the current rendering target at subpixel precision.
    pub inline fn drawRects(self: *const Renderer, rects: []const FRect) !void {
        try errify(c.SDL_RenderRects(self.ptr, rects.ptr, @intCast(rects.len)));
    }

    /// Fill a rectangle on the current rendering target with the drawing color at subpixel precision.
    pub inline fn fillRect(self: *const Renderer, rect: ?*const FRect) !void {
        try errify(c.SDL_RenderFillRect(self.ptr, rect));
    }

    /// Fill some number of rectangles on the current rendering target with the drawing color at subpixel precision.
    pub inline fn fillRects(self: *const Renderer, rects: []const FRect) !void {
        try errify(c.SDL_RenderFillRects(self.ptr, rects.ptr, @intCast(rects.len)));
    }

    /// Copy a portion of the texture to the current rendering target at subpixel precision.
    pub inline fn copyTexture(self: *const Renderer, texture: *const Texture, src_rect: ?*const FRect, dst_rect: ?*const FRect) !void {
        try errify(c.SDL_RenderTexture(self.ptr, texture.ptr, src_rect, dst_rect));
    }

    /// Copy a portion of the source texture to the current rendering target, with rotation and flipping, at subpixel precision.
    pub inline fn copyTextureRotated(self: *const Renderer, texture: *const Texture, src_rect: ?*const FRect, dst_rect: ?*const FRect, angle: f64, center: ?FPoint, flip: c.SDL_FlipMode) !void {
        try errify(c.SDL_RenderTextureRotated(self.ptr, texture.ptr, src_rect, dst_rect, angle, @ptrCast(&center), flip));
    }

    /// Copy a portion of the source texture to the current rendering target, with affine transform, at subpixel precision.
    pub inline fn copyTextureAffine(self: *const Renderer, texture: *const Texture, src_rect: ?*const FRect, origin: ?*const FPoint, right: ?*const FPoint, down: ?FPoint) !void {
        try errify(c.SDL_RenderTextureAffine(self.ptr, texture.ptr, src_rect, origin, right, @ptrCast(&down)));
    }

    /// Tile a portion of the texture to the current rendering target at subpixel precision.
    pub inline fn copyTextureTiled(self: *const Renderer, texture: *const Texture, src_rect: ?*const FRect, scale: f32, dst_rect: ?*const FRect) !void {
        try errify(c.SDL_RenderTextureTiled(self.ptr, texture.ptr, src_rect, scale, dst_rect));
    }

    /// Perform a scaled copy using the 9-grid algorithm to the current rendering target at subpixel precision.
    pub inline fn copyTexture9Grid(self: *const Renderer, texture: *const Texture, src_rect: ?*const FRect, left_width: f32, right_width: f32, top_height: f32, bottom_height: f32, scale: f32, dst_rect: ?*const FRect) !void {
        try errify(c.SDL_RenderTexture9Grid(self.ptr, texture.ptr, src_rect, left_width, right_width, top_height, bottom_height, scale, dst_rect));
    }

    /// Render a list of triangles, optionally using a texture and indices into the vertex array.
    pub inline fn drawGeometry(self: *const Renderer, texture: ?*Texture, vertices: []const c.SDL_Vertex, indices: ?[]const c_int) !void {
        try errify(c.SDL_RenderGeometry(
            self.ptr,
            if (texture) |t| t.ptr else null,
            vertices.ptr,
            @intCast(vertices.len),
            if (indices) |i| i.ptr else null,
            if (indices) |i| @intCast(i.len) else 0,
        ));
    }

    /// Render a list of triangles with raw vertex data.
    pub inline fn drawGeometryRaw(self: *const Renderer, texture: ?*Texture, xy: []const f32, xy_stride: c_int, color: []const c.SDL_FColor, color_stride: c_int, uv: []const f32, uv_stride: c_int, indices: ?[]const u8, size_indices: c_int) !void {
        try errify(c.SDL_RenderGeometryRaw(
            self.ptr,
            if (texture) |t| t.ptr else null,
            xy.ptr,
            xy_stride,
            color.ptr,
            color_stride,
            uv.ptr,
            uv_stride,
            @intCast(xy.len),
            if (indices) |i| i.ptr else null,
            if (indices) |i| @intCast(i.len) else 0,
            size_indices,
        ));
    }

    /// Read pixels from the current rendering target.
    pub inline fn readPixels(self: *const Renderer, rect: ?*const c.SDL_Rect) !*c.SDL_Surface {
        const surface = c.SDL_RenderReadPixels(self.ptr, rect);
        try errify(surface != null);
        return surface.?;
    }

    /// Update the screen with any rendering performed since the previous call.
    pub inline fn present(self: *const Renderer) !void {
        try errify(c.SDL_RenderPresent(self.ptr));
    }

    /// Force the rendering context to flush any pending commands and state.
    pub inline fn flush(self: *const Renderer) !void {
        try errify(c.SDL_FlushRenderer(self.ptr));
    }

    /// Get the CAMetalLayer associated with the given Metal renderer.
    pub inline fn getMetalLayer(self: *const Renderer) ?*anyopaque {
        return c.SDL_GetRenderMetalLayer(self.ptr);
    }

    /// Get the Metal command encoder for the current frame.
    pub inline fn getMetalCommandEncoder(self: *const Renderer) ?*anyopaque {
        return c.SDL_GetRenderMetalCommandEncoder(self.ptr);
    }

    /// Add a set of synchronization semaphores for the current frame.
    pub inline fn addVulkanRenderSemaphores(self: *const Renderer, wait_stage_mask: u32, wait_semaphore: i64, signal_semaphore: i64) !void {
        try errify(c.SDL_AddVulkanRenderSemaphores(self.ptr, wait_stage_mask, wait_semaphore, signal_semaphore));
    }

    /// Toggle VSync of the given renderer.
    pub inline fn setVSync(self: *const Renderer, vsync: c_int) !void {
        try errify(c.SDL_SetRenderVSync(self.ptr, vsync));
    }

    /// Get VSync of the given renderer.
    pub inline fn getVSync(self: *const Renderer) !c_int {
        var vsync: c_int = undefined;
        try errify(c.SDL_GetRenderVSync(self.ptr, &vsync));
        return vsync;
    }

    /// Draw debug text to an SDL_Renderer.
    pub inline fn drawDebugText(self: *const Renderer, x: f32, y: f32, text: [*:0]const u8) !void {
        try errify(c.SDL_RenderDebugText(self.ptr, x, y, text));
    }

    /// Draw debug text to an SDL_Renderer with format.
    pub inline fn drawDebugTextFormat(self: *const Renderer, x: f32, y: f32, comptime format: []const u8, args: anytype) !void {
        try errify(c.SDL_RenderDebugTextFormat(self.ptr, x, y, format.ptr, args));
    }

    /// Destroy the renderer and free all associated textures.
    pub inline fn destroy(self: *const Renderer) void {
        c.SDL_DestroyRenderer(self.ptr);
    }
};

pub const Texture = struct {
    ptr: *c.SDL_Texture,

    /// Get the renderer that created the texture.
    pub inline fn getRenderer(self: *const Texture) !Renderer {
        const renderer = c.SDL_GetRendererFromTexture(self.ptr);
        try errify(renderer != null);
        return Renderer{ .ptr = renderer.? };
    }

    /// Get the size of a texture in pixels.
    pub inline fn getSize(self: *const Texture) !struct { w: f32, h: f32 } {
        var w: f32 = undefined;
        var h: f32 = undefined;
        try errify(c.SDL_GetTextureSize(self.ptr, &w, &h));
        return .{ .w = w, .h = h };
    }

    /// Set an additional color value multiplied into render copy operations.
    pub inline fn setColorMod(self: *const Texture, r: u8, g: u8, b: u8) !void {
        try errify(c.SDL_SetTextureColorMod(self.ptr, r, g, b));
    }

    /// Set an additional color value multiplied into render copy operations.
    pub inline fn setColorModFloat(self: *const Texture, r: f32, g: f32, b: f32) !void {
        try errify(c.SDL_SetTextureColorModFloat(self.ptr, r, g, b));
    }

    /// Get the additional color value multiplied into render copy operations.
    pub inline fn getColorMod(self: *const Texture) !struct { r: u8, g: u8, b: u8 } {
        var r: u8 = undefined;
        var g: u8 = undefined;
        var b: u8 = undefined;
        try errify(c.SDL_GetTextureColorMod(self.ptr, &r, &g, &b));
        return .{ .r = r, .g = g, .b = b };
    }

    /// Get the additional color value multiplied into render copy operations.
    pub inline fn getColorModFloat(self: *const Texture) !struct { r: f32, g: f32, b: f32 } {
        var r: f32 = undefined;
        var g: f32 = undefined;
        var b: f32 = undefined;
        try errify(c.SDL_GetTextureColorModFloat(self.ptr, &r, &g, &b));
        return .{ .r = r, .g = g, .b = b };
    }

    /// Set an additional alpha value multiplied into render copy operations.
    pub inline fn setAlphaMod(self: *const Texture, alpha: u8) !void {
        try errify(c.SDL_SetTextureAlphaMod(self.ptr, alpha));
    }

    /// Set an additional alpha value multiplied into render copy operations.
    pub inline fn setAlphaModFloat(self: *const Texture, alpha: f32) !void {
        try errify(c.SDL_SetTextureAlphaModFloat(self.ptr, alpha));
    }

    /// Get the additional alpha value multiplied into render copy operations.
    pub inline fn getAlphaMod(self: *const Texture) !u8 {
        var alpha: u8 = undefined;
        try errify(c.SDL_GetTextureAlphaMod(self.ptr, &alpha));
        return alpha;
    }

    /// Get the additional alpha value multiplied into render copy operations.
    pub inline fn getAlphaModFloat(self: *const Texture) !f32 {
        var alpha: f32 = undefined;
        try errify(c.SDL_GetTextureAlphaModFloat(self.ptr, &alpha));
        return alpha;
    }

    /// Set the blend mode for a texture.
    pub inline fn setBlendMode(self: *const Texture, blend_mode: c.SDL_BlendMode) !void {
        try errify(c.SDL_SetTextureBlendMode(self.ptr, blend_mode));
    }

    /// Get the blend mode used for texture copy operations.
    pub inline fn getBlendMode(self: *const Texture) !c.SDL_BlendMode {
        var blend_mode: c.SDL_BlendMode = undefined;
        try errify(c.SDL_GetTextureBlendMode(self.ptr, &blend_mode));
        return blend_mode;
    }

    /// Set the scale mode used for texture scale operations.
    pub inline fn setScaleMode(self: *const Texture, scale_mode: c.SDL_ScaleMode) !void {
        try errify(c.SDL_SetTextureScaleMode(self.ptr, scale_mode));
    }

    /// Get the scale mode used for texture scale operations.
    pub inline fn getScaleMode(self: *const Texture) !c.SDL_ScaleMode {
        var scale_mode: c.SDL_ScaleMode = undefined;
        try errify(c.SDL_GetTextureScaleMode(self.ptr, &scale_mode));
        return scale_mode;
    }

    /// Update the given texture rectangle with new pixel data.
    pub inline fn update(self: *const Texture, rect: ?*const c.SDL_Rect, pixels: *const anyopaque, pitch: c_int) !void {
        try errify(c.SDL_UpdateTexture(self.ptr, rect, pixels, pitch));
    }

    /// Update a rectangle within a planar YV12 or IYUV texture with new pixel data.
    pub inline fn updateYUV(self: *const Texture, rect: ?*const c.SDL_Rect, y_plane: [*]const u8, y_pitch: c_int, u_plane: [*]const u8, u_pitch: c_int, v_plane: [*]const u8, v_pitch: c_int) !void {
        try errify(c.SDL_UpdateYUVTexture(self.ptr, rect, y_plane, y_pitch, u_plane, u_pitch, v_plane, v_pitch));
    }

    /// Update a rectangle within a planar NV12 or NV21 texture with new pixels.
    pub inline fn updateNV(self: *const Texture, rect: ?*const c.SDL_Rect, y_plane: [*]const u8, y_pitch: c_int, uv_plane: [*]const u8, uv_pitch: c_int) !void {
        try errify(c.SDL_UpdateNVTexture(self.ptr, rect, y_plane, y_pitch, uv_plane, uv_pitch));
    }

    /// Lock a portion of the texture for write-only pixel access.
    pub inline fn lock(self: *const Texture, rect: ?*const c.SDL_Rect) !struct { pixels: *anyopaque, pitch: c_int } {
        var pixels: ?*anyopaque = undefined;
        var pitch: c_int = undefined;
        try errify(c.SDL_LockTexture(self.ptr, rect, &pixels, &pitch));
        return .{ .pixels = pixels.?, .pitch = pitch };
    }

    /// Lock a portion of the texture for write-only pixel access and expose it as a SDL surface.
    pub inline fn lockToSurface(self: *const Texture, rect: ?*const c.SDL_Rect) !*c.SDL_Surface {
        var surface: ?*c.SDL_Surface = undefined;
        try errify(c.SDL_LockTextureToSurface(self.ptr, rect, &surface));
        return surface.?;
    }

    /// Unlock a texture, uploading the changes to video memory, if needed.
    pub inline fn unlock(self: *const Texture) void {
        c.SDL_UnlockTexture(self.ptr);
    }

    /// Get the properties associated with a texture.
    pub inline fn getProperties(self: *const Texture) !c.SDL_PropertiesID {
        return errify(c.SDL_GetTextureProperties(self.ptr));
    }

    /// Destroy the specified texture.
    pub inline fn destroy(self: *const Texture) void {
        c.SDL_DestroyTexture(self.ptr);
    }
};

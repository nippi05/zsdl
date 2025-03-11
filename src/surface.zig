const std = @import("std");

const BlendMode = @import("blendmode.zig").BlendMode;
const c = @import("c.zig").c;
const errify = @import("internal.zig").errify;
const pixels = @import("pixels.zig");
const PixelFormat = pixels.PixelFormat;
const Colorspace = pixels.Colorspace;
const Palette = pixels.Palette;
const rect = @import("rect.zig");

pub const ScaleMode = enum(u32) {
    nearest = c.SDL_SCALEMODE_NEAREST,
    linear = c.SDL_SCALEMODE_LINEAR,
};

pub const FlipMode = enum(u32) {
    none = c.SDL_FLIP_NONE,
    horizontal = c.SDL_FLIP_HORIZONTAL,
    vertical = c.SDL_FLIP_VERTICAL,
};

pub const Surface = struct {
    ptr: *c.SDL_Surface,

    /// Creates a new Surface that can be safely destroyed with deinit().
    pub inline fn create(width: usize, height: usize, format: PixelFormat) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_CreateSurface(@intCast(width), @intCast(height), @intFromEnum(format))),
        };
    }

    /// Creates a new Surface from existing pixel data.
    pub inline fn createFrom(width: usize, height: usize, format: PixelFormat, pixels_ptr: ?*anyopaque, pitch: usize) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_CreateSurfaceFrom(@intCast(width), @intCast(height), @intFromEnum(format), pixels_ptr, @intCast(pitch))),
        };
    }

    /// Destroys the Surface and frees its associated memory.
    pub inline fn destroy(self: *const Surface) void {
        c.SDL_DestroySurface(self.ptr);
    }

    /// Gets the properties associated with the surface.
    pub inline fn getProperties(self: *const Surface) c.SDL_PropertiesID {
        return c.SDL_GetSurfaceProperties(self.ptr);
    }

    /// Sets the colorspace used by the surface.
    pub inline fn setColorspace(self: *const Surface, colorspace: Colorspace) !void {
        try errify(c.SDL_SetSurfaceColorspace(self.ptr, @intFromEnum(colorspace)));
    }

    /// Gets the colorspace used by the surface.
    pub inline fn getColorspace(self: *const Surface) Colorspace {
        return @enumFromInt(c.SDL_GetSurfaceColorspace(self.ptr));
    }

    /// Creates a palette and associates it with the surface.
    pub inline fn createPalette(self: *const Surface) !Palette {
        return .{
            .ptr = try errify(c.SDL_CreateSurfacePalette(self.ptr)),
        };
    }

    /// Sets the palette used by the surface.
    pub inline fn setPalette(self: *const Surface, palette: Palette) !void {
        try errify(c.SDL_SetSurfacePalette(self.ptr, palette.ptr));
    }

    /// Gets the palette used by the surface.
    pub inline fn getPalette(self: *const Surface) Palette {
        return .{
            .ptr = c.SDL_GetSurfacePalette(self.ptr),
        };
    }

    /// Adds an alternate version of the surface.
    pub inline fn addAlternateImage(self: *const Surface, image: *const Surface) !void {
        try errify(c.SDL_AddSurfaceAlternateImage(self.ptr, image.ptr));
    }

    /// Returns whether the surface has alternate versions available.
    pub inline fn hasAlternateImages(self: *const Surface) bool {
        return c.SDL_SurfaceHasAlternateImages(self.ptr);
    }

    /// Gets an array including all versions of the surface.
    pub inline fn getImages(self: *const Surface) ![]Surface {
        var count: c_int = undefined;
        const images = try errify(c.SDL_GetSurfaceImages(self.ptr, &count));
        return @ptrCast(images[0..@intCast(count)]);
    }

    /// Removes all alternate versions of the surface.
    pub inline fn removeAlternateImages(self: *const Surface) void {
        c.SDL_RemoveSurfaceAlternateImages(self.ptr);
    }

    /// Sets up the surface for directly accessing the pixels.
    pub inline fn lock(self: *const Surface) !void {
        try errify(c.SDL_LockSurface(self.ptr));
    }

    /// Releases the surface after directly accessing the pixels.
    pub inline fn unlock(self: *const Surface) void {
        c.SDL_UnlockSurface(self.ptr);
    }

    /// Load a BMP image from a file.
    pub inline fn loadBMP(file: []const u8) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_LoadBMP(file.ptr)),
        };
    }

    /// Save the surface to a file in BMP format.
    pub inline fn saveBMP(self: *const Surface, file: []const u8) !void {
        try errify(c.SDL_SaveBMP(self.ptr, file.ptr));
    }

    /// Sets the RLE acceleration hint for the surface.
    pub inline fn setRLE(self: *const Surface, enabled: bool) !void {
        try errify(c.SDL_SetSurfaceRLE(self.ptr, enabled));
    }

    /// Returns whether the surface is RLE enabled.
    pub inline fn hasRLE(self: *const Surface) bool {
        return c.SDL_SurfaceHasRLE(self.ptr);
    }

    /// Sets the color key (transparent pixel) in the surface.
    pub inline fn setColorKey(self: *const Surface, enabled: bool, key: u32) !void {
        try errify(c.SDL_SetSurfaceColorKey(self.ptr, enabled, key));
    }

    /// Returns whether the surface has a color key.
    pub inline fn hasColorKey(self: *const Surface) bool {
        return c.SDL_SurfaceHasColorKey(self.ptr);
    }

    /// Gets the color key (transparent pixel) for the surface.
    pub inline fn getColorKey(self: *const Surface) !u32 {
        var key: u32 = undefined;
        try errify(c.SDL_GetSurfaceColorKey(self.ptr, &key));
        return key;
    }

    /// Sets an additional color value multiplied into blit operations.
    pub inline fn setColorMod(self: *const Surface, r: u8, g: u8, b: u8) !void {
        try errify(c.SDL_SetSurfaceColorMod(self.ptr, r, g, b));
    }

    /// Gets the additional color value multiplied into blit operations.
    pub inline fn getColorMod(self: *const Surface) !struct { r: u8, g: u8, b: u8 } {
        var r: u8 = undefined;
        var g: u8 = undefined;
        var b: u8 = undefined;
        try errify(c.SDL_GetSurfaceColorMod(self.ptr, &r, &g, &b));
        return .{ .r = r, .g = g, .b = b };
    }

    /// Sets an additional alpha value used in blit operations.
    pub inline fn setAlphaMod(self: *const Surface, alpha: u8) !void {
        try errify(c.SDL_SetSurfaceAlphaMod(self.ptr, alpha));
    }

    /// Gets the additional alpha value used in blit operations.
    pub inline fn getAlphaMod(self: *const Surface) !u8 {
        var alpha: u8 = undefined;
        try errify(c.SDL_GetSurfaceAlphaMod(self.ptr, &alpha));
        return alpha;
    }

    /// Sets the blend mode used for blit operations.
    pub inline fn setBlendMode(self: *const Surface, blend_mode: BlendMode) !void {
        try errify(c.SDL_SetSurfaceBlendMode(self.ptr, @intFromEnum(blend_mode)));
    }

    /// Gets the blend mode used for blit operations.
    pub inline fn getBlendMode(self: *const Surface) !BlendMode {
        var blend_mode: c.SDL_BlendMode = undefined;
        try errify(c.SDL_GetSurfaceBlendMode(self.ptr, &blend_mode));
        return @enumFromInt(blend_mode);
    }

    /// Sets the clipping rectangle for the surface.
    pub inline fn setClipRect(self: *const Surface, rect_opt: ?rect.Rect) !void {
        const rect_ptr: ?*const c.SDL_Rect = if (rect_opt) |r| @ptrCast(&r) else null;
        try errify(c.SDL_SetSurfaceClipRect(self.ptr, rect_ptr));
    }

    /// Gets the clipping rectangle for the surface.
    pub inline fn getClipRect(self: *const Surface) !rect.Rect {
        var r: c.SDL_Rect = undefined;
        try errify(c.SDL_GetSurfaceClipRect(self.ptr, &r));
        return @bitCast(r);
    }

    /// Flips the surface vertically or horizontally.
    pub inline fn flip(self: *const Surface, flip_mode: FlipMode) !void {
        try errify(c.SDL_FlipSurface(self.ptr, @intFromEnum(flip_mode)));
    }

    /// Creates a new surface identical to the existing surface.
    pub inline fn duplicate(self: *const Surface) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_DuplicateSurface(self.ptr)),
        };
    }

    /// Creates a new surface identical to the existing surface, scaled to the desired size.
    pub inline fn scale(self: *const Surface, width: usize, height: usize, scale_mode: ScaleMode) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_ScaleSurface(self.ptr, @intCast(width), @intCast(height), @intFromEnum(scale_mode))),
        };
    }

    /// Converts the surface to a new format.
    pub inline fn convert(self: *const Surface, format: PixelFormat) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_ConvertSurface(self.ptr, @intFromEnum(format))),
        };
    }

    /// Clears the surface with a specific color.
    pub inline fn clear(self: *const Surface, r: f32, g: f32, b: f32, a: f32) !void {
        try errify(c.SDL_ClearSurface(self.ptr, r, g, b, a));
    }

    /// Performs a fast fill of a rectangle with a specific color.
    pub inline fn fillRect(self: *const Surface, rect_opt: ?rect.Rect, color: u32) !void {
        const rect_ptr: ?*const c.SDL_Rect = if (rect_opt) |r| @ptrCast(&r) else null;
        try errify(c.SDL_FillSurfaceRect(self.ptr, rect_ptr, color));
    }

    /// Performs a fast fill of a set of rectangles with a specific color.
    pub inline fn fillRects(self: *const Surface, rects: []const rect.Rect, color: u32) !void {
        var native_rects = try std.ArrayList(c.SDL_Rect).initCapacity(std.heap.c_allocator, rects.len);
        defer native_rects.deinit();

        for (rects) |r| {
            // Since rect.Rect is already extern struct matching SDL_Rect,
            // we can directly bitcast or reinterpret the memory
            native_rects.appendAssumeCapacity(@bitCast(r));
        }

        try errify(c.SDL_FillSurfaceRects(self.ptr, native_rects.items.ptr, @intCast(rects.len), color));
    }

    /// Performs a fast blit from the source surface to the destination surface.
    pub inline fn blit(self: *const Surface, src_rect: ?rect.Rect, dst: *Surface, dst_rect: ?*rect.Rect) !void {
        const src_rect_ptr: ?*const c.SDL_Rect = if (src_rect) |*r| @ptrCast(r) else null;
        const dst_rect_ptr: ?*c.SDL_Rect = if (dst_rect) |r| @ptrCast(r) else null;
        try errify(c.SDL_BlitSurface(self.ptr, src_rect_ptr, dst.ptr, dst_rect_ptr));
    }

    /// Performs a scaled blit from the source surface to the destination surface.
    pub inline fn blitScaled(
        self: *const Surface,
        src_rect: ?rect.Rect,
        dst: *Surface,
        dst_rect: ?rect.Rect,
        scale_mode: ScaleMode,
    ) !void {
        const src_rect_ptr: ?*const c.SDL_Rect = if (src_rect) |*r| @ptrCast(r) else null;
        const dst_rect_ptr: ?*const c.SDL_Rect = if (dst_rect) |*r| @ptrCast(r) else null;
        try errify(c.SDL_BlitSurfaceScaled(
            self.ptr,
            src_rect_ptr,
            dst.ptr,
            dst_rect_ptr,
            @intFromEnum(scale_mode),
        ));
    }

    /// Maps an RGB triple to an opaque pixel value for the surface.
    pub inline fn mapRGB(self: *const Surface, r: u8, g: u8, b: u8) u32 {
        return c.SDL_MapSurfaceRGB(self.ptr, r, g, b);
    }

    /// Maps an RGBA quadruple to a pixel value for the surface.
    pub inline fn mapRGBA(self: *const Surface, r: u8, g: u8, b: u8, a: u8) u32 {
        return c.SDL_MapSurfaceRGBA(self.ptr, r, g, b, a);
    }

    /// Retrieves a single pixel from the surface.
    pub inline fn readPixel(self: *const Surface, x: usize, y: usize) !struct { r: u8, g: u8, b: u8, a: u8 } {
        var r: u8 = undefined;
        var g: u8 = undefined;
        var b: u8 = undefined;
        var a: u8 = undefined;
        try errify(c.SDL_ReadSurfacePixel(self.ptr, @intCast(x), @intCast(y), &r, &g, &b, &a));
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// Retrieves a single pixel from the surface as floating point values.
    pub inline fn readPixelFloat(self: *const Surface, x: usize, y: usize) !struct { r: f32, g: f32, b: f32, a: f32 } {
        var r: f32 = undefined;
        var g: f32 = undefined;
        var b: f32 = undefined;
        var a: f32 = undefined;
        try errify(c.SDL_ReadSurfacePixelFloat(self.ptr, @intCast(x), @intCast(y), &r, &g, &b, &a));
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// Writes a single pixel to the surface.
    pub inline fn writePixel(self: *const Surface, x: usize, y: usize, r: u8, g: u8, b: u8, a: u8) !void {
        try errify(c.SDL_WriteSurfacePixel(self.ptr, @intCast(x), @intCast(y), r, g, b, a));
    }

    /// Writes a single pixel to the surface using floating point values.
    pub inline fn writePixelFloat(self: *const Surface, x: usize, y: usize, r: f32, g: f32, b: f32, a: f32) !void {
        try errify(c.SDL_WriteSurfacePixelFloat(self.ptr, @intCast(x), @intCast(y), r, g, b, a));
    }

    /// Performs a low-level surface blitting only.
    pub inline fn blitUnchecked(self: *const Surface, src_rect: rect.Rect, dst: *Surface, dst_rect: rect.Rect) !void {
        var src_r: c.SDL_Rect = @bitCast(src_rect);
        var dst_r: c.SDL_Rect = @bitCast(dst_rect);
        try errify(c.SDL_BlitSurfaceUnchecked(self.ptr, &src_r, dst.ptr, &dst_r));
    }

    /// Performs a low-level surface scaled blitting only.
    pub inline fn blitUncheckedScaled(self: *const Surface, src_rect: rect.Rect, dst: *Surface, dst_rect: rect.Rect, scale_mode: ScaleMode) !void {
        var src_r: c.SDL_Rect = @bitCast(src_rect);
        var dst_r: c.SDL_Rect = @bitCast(dst_rect);
        try errify(c.SDL_BlitSurfaceUncheckedScaled(self.ptr, &src_r, dst.ptr, &dst_r, @intFromEnum(scale_mode)));
    }

    /// Performs a stretched pixel copy from one surface to another.
    pub inline fn stretch(self: *const Surface, src_rect: rect.Rect, dst: *Surface, dst_rect: rect.Rect, scale_mode: ScaleMode) !void {
        var src_r: c.SDL_Rect = @bitCast(src_rect);
        var dst_r: c.SDL_Rect = @bitCast(dst_rect);
        try errify(c.SDL_StretchSurface(self.ptr, &src_r, dst.ptr, &dst_r, @intFromEnum(scale_mode)));
    }

    /// Performs a tiled blit to a destination surface.
    pub inline fn blitTiled(self: *const Surface, src_rect: ?rect.Rect, dst: *Surface, dst_rect: ?rect.Rect) !void {
        const src_rect_ptr: ?*const c.SDL_Rect = if (src_rect) |*r| @ptrCast(r) else null;
        const dst_rect_ptr: ?*const c.SDL_Rect = if (dst_rect) |*r| @ptrCast(r) else null;
        try errify(c.SDL_BlitSurfaceTiled(self.ptr, src_rect_ptr, dst.ptr, dst_rect_ptr));
    }

    /// Performs a scaled and tiled blit to a destination surface.
    pub inline fn blitTiledWithScale(
        self: *const Surface,
        src_rect: ?rect.Rect,
        scale_val: f32,
        scale_mode: ScaleMode,
        dst: *Surface,
        dst_rect: ?rect.Rect,
    ) !void {
        const src_rect_ptr: ?*const c.SDL_Rect = if (src_rect) |*r| @ptrCast(r) else null;
        const dst_rect_ptr: ?*const c.SDL_Rect = if (dst_rect) |*r| @ptrCast(r) else null;
        try errify(c.SDL_BlitSurfaceTiledWithScale(
            self.ptr,
            src_rect_ptr,
            scale_val,
            @intFromEnum(scale_mode),
            dst.ptr,
            dst_rect_ptr,
        ));
    }

    /// Performs a scaled blit using the 9-grid algorithm.
    pub inline fn blit9Grid(
        self: *const Surface,
        src_rect: ?rect.Rect,
        left_width: usize,
        right_width: usize,
        top_height: usize,
        bottom_height: usize,
        scale_val: f32,
        scale_mode: ScaleMode,
        dst: *Surface,
        dst_rect: ?rect.Rect,
    ) !void {
        const src_rect_ptr: ?*const c.SDL_Rect = if (src_rect) |*r| @ptrCast(r) else null;
        const dst_rect_ptr: ?*const c.SDL_Rect = if (dst_rect) |*r| @ptrCast(r) else null;
        try errify(c.SDL_BlitSurface9Grid(
            self.ptr,
            src_rect_ptr,
            @intCast(left_width),
            @intCast(right_width),
            @intCast(top_height),
            @intCast(bottom_height),
            scale_val,
            @intFromEnum(scale_mode),
            dst.ptr,
            dst_rect_ptr,
        ));
    }

    /// Premultiply the alpha in a surface.
    pub inline fn premultiplyAlpha(self: *const Surface, linear: bool) !void {
        try errify(c.SDL_PremultiplySurfaceAlpha(self.ptr, linear));
    }
};

/// Copy a block of pixels of one format to another format.
pub inline fn convertPixels(
    width: usize,
    height: usize,
    src_format: PixelFormat,
    src: *const anyopaque,
    src_pitch: usize,
    dst_format: PixelFormat,
    dst: *anyopaque,
    dst_pitch: usize,
) !void {
    try errify(c.SDL_ConvertPixels(
        @intCast(width),
        @intCast(height),
        @intFromEnum(src_format),
        src,
        @intCast(src_pitch),
        @intFromEnum(dst_format),
        dst,
        @intCast(dst_pitch),
    ));
}

/// Copy a block of pixels of one format and colorspace to another format and colorspace.
pub inline fn convertPixelsAndColorspace(
    width: usize,
    height: usize,
    src_format: PixelFormat,
    src_colorspace: Colorspace,
    src_properties: c.SDL_PropertiesID,
    src: *const anyopaque,
    src_pitch: usize,
    dst_format: PixelFormat,
    dst_colorspace: Colorspace,
    dst_properties: c.SDL_PropertiesID,
    dst: *anyopaque,
    dst_pitch: usize,
) !void {
    try errify(c.SDL_ConvertPixelsAndColorspace(
        @intCast(width),
        @intCast(height),
        @intFromEnum(src_format),
        @intFromEnum(src_colorspace),
        src_properties,
        src,
        @intCast(src_pitch),
        @intFromEnum(dst_format),
        @intFromEnum(dst_colorspace),
        dst_properties,
        dst,
        @intCast(dst_pitch),
    ));
}

/// Premultiply the alpha on a block of pixels.
pub inline fn premultiplyAlpha(
    width: usize,
    height: usize,
    src_format: PixelFormat,
    src: *const anyopaque,
    src_pitch: usize,
    dst_format: PixelFormat,
    dst: *anyopaque,
    dst_pitch: usize,
    linear: bool,
) !void {
    try errify(c.SDL_PremultiplyAlpha(
        @intCast(width),
        @intCast(height),
        @intFromEnum(src_format),
        src,
        @intCast(src_pitch),
        @intFromEnum(dst_format),
        dst,
        @intCast(dst_pitch),
        linear,
    ));
}

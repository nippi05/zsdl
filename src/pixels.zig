const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;

pub const PixelFormat = enum(u32) {
    unknown = c.SDL_PIXELFORMAT_UNKNOWN,
    index1lsb = c.SDL_PIXELFORMAT_INDEX1LSB,
    index1msb = c.SDL_PIXELFORMAT_INDEX1MSB,
    index2lsb = c.SDL_PIXELFORMAT_INDEX2LSB,
    index2msb = c.SDL_PIXELFORMAT_INDEX2MSB,
    index4lsb = c.SDL_PIXELFORMAT_INDEX4LSB,
    index4msb = c.SDL_PIXELFORMAT_INDEX4MSB,
    index8 = c.SDL_PIXELFORMAT_INDEX8,
    rgb332 = c.SDL_PIXELFORMAT_RGB332,
    xrgb4444 = c.SDL_PIXELFORMAT_XRGB4444,
    xbgr4444 = c.SDL_PIXELFORMAT_XBGR4444,
    xrgb1555 = c.SDL_PIXELFORMAT_XRGB1555,
    xbgr1555 = c.SDL_PIXELFORMAT_XBGR1555,
    argb4444 = c.SDL_PIXELFORMAT_ARGB4444,
    rgba4444 = c.SDL_PIXELFORMAT_RGBA4444,
    abgr4444 = c.SDL_PIXELFORMAT_ABGR4444,
    bgra4444 = c.SDL_PIXELFORMAT_BGRA4444,
    argb1555 = c.SDL_PIXELFORMAT_ARGB1555,
    rgba5551 = c.SDL_PIXELFORMAT_RGBA5551,
    abgr1555 = c.SDL_PIXELFORMAT_ABGR1555,
    bgra5551 = c.SDL_PIXELFORMAT_BGRA5551,
    rgb565 = c.SDL_PIXELFORMAT_RGB565,
    bgr565 = c.SDL_PIXELFORMAT_BGR565,
    rgb24 = c.SDL_PIXELFORMAT_RGB24,
    bgr24 = c.SDL_PIXELFORMAT_BGR24,
    xrgb8888 = c.SDL_PIXELFORMAT_XRGB8888,
    rgbx8888 = c.SDL_PIXELFORMAT_RGBX8888,
    xbgr8888 = c.SDL_PIXELFORMAT_XBGR8888,
    bgrx8888 = c.SDL_PIXELFORMAT_BGRX8888,
    argb8888 = c.SDL_PIXELFORMAT_ARGB8888,
    rgba8888 = c.SDL_PIXELFORMAT_RGBA8888,
    abgr8888 = c.SDL_PIXELFORMAT_ABGR8888,
    bgra8888 = c.SDL_PIXELFORMAT_BGRA8888,
    xrgb2101010 = c.SDL_PIXELFORMAT_XRGB2101010,
    xbgr2101010 = c.SDL_PIXELFORMAT_XBGR2101010,
    argb2101010 = c.SDL_PIXELFORMAT_ARGB2101010,
    abgr2101010 = c.SDL_PIXELFORMAT_ABGR2101010,
    rgb48 = c.SDL_PIXELFORMAT_RGB48,
    bgr48 = c.SDL_PIXELFORMAT_BGR48,
    rgba64 = c.SDL_PIXELFORMAT_RGBA64,
    argb64 = c.SDL_PIXELFORMAT_ARGB64,
    bgra64 = c.SDL_PIXELFORMAT_BGRA64,
    abgr64 = c.SDL_PIXELFORMAT_ABGR64,
    rgb48_float = c.SDL_PIXELFORMAT_RGB48_FLOAT,
    bgr48_float = c.SDL_PIXELFORMAT_BGR48_FLOAT,
    rgba64_float = c.SDL_PIXELFORMAT_RGBA64_FLOAT,
    argb64_float = c.SDL_PIXELFORMAT_ARGB64_FLOAT,
    bgra64_float = c.SDL_PIXELFORMAT_BGRA64_FLOAT,
    abgr64_float = c.SDL_PIXELFORMAT_ABGR64_FLOAT,
    rgb96_float = c.SDL_PIXELFORMAT_RGB96_FLOAT,
    bgr96_float = c.SDL_PIXELFORMAT_BGR96_FLOAT,
    rgba128_float = c.SDL_PIXELFORMAT_RGBA128_FLOAT,
    argb128_float = c.SDL_PIXELFORMAT_ARGB128_FLOAT,
    bgra128_float = c.SDL_PIXELFORMAT_BGRA128_FLOAT,
    abgr128_float = c.SDL_PIXELFORMAT_ABGR128_FLOAT,
    yv12 = c.SDL_PIXELFORMAT_YV12,
    iyuv = c.SDL_PIXELFORMAT_IYUV,
    yuy2 = c.SDL_PIXELFORMAT_YUY2,
    uyvy = c.SDL_PIXELFORMAT_UYVY,
    yvyu = c.SDL_PIXELFORMAT_YVYU,
    nv12 = c.SDL_PIXELFORMAT_NV12,
    nv21 = c.SDL_PIXELFORMAT_NV21,
    p010 = c.SDL_PIXELFORMAT_P010,
    external_oes = c.SDL_PIXELFORMAT_EXTERNAL_OES,

    /// Get the human readable name of a pixel format
    pub inline fn getName(self: PixelFormat) []const u8 {
        return std.mem.span(c.SDL_GetPixelFormatName(@intFromEnum(self)));
    }
};

pub const ColorSpace = enum(u32) {
    unknown = c.SDL_COLORSPACE_UNKNOWN,
    srgb = c.SDL_COLORSPACE_SRGB,
    srgb_linear = c.SDL_COLORSPACE_SRGB_LINEAR,
    hdr10 = c.SDL_COLORSPACE_HDR10,
    jpeg = c.SDL_COLORSPACE_JPEG,
    bt601_limited = c.SDL_COLORSPACE_BT601_LIMITED,
    bt601_full = c.SDL_COLORSPACE_BT601_FULL,
    bt709_limited = c.SDL_COLORSPACE_BT709_LIMITED,
    bt709_full = c.SDL_COLORSPACE_BT709_FULL,
    bt2020_limited = c.SDL_COLORSPACE_BT2020_LIMITED,
    bt2020_full = c.SDL_COLORSPACE_BT2020_FULL,

    pub const rgb_default: ColorSpace = c.SDL_COLORSPACE_RGB_DEFAULT;
    pub const yuv_default: ColorSpace = c.SDL_COLORSPACE_YUV_DEFAULT;
};

pub const Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

pub const FColor = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Palette = struct {
    ptr: *c.SDL_Palette,

    /// Create a palette structure with the specified number of color entries.
    pub inline fn create(ncolors: i32) !Palette {
        const palette = c.SDL_CreatePalette(ncolors);
        try errify(palette != null);
        return .{
            .ptr = palette,
        };
    }

    /// Set a range of colors in a palette.
    pub inline fn setColors(self: *const Palette, colors: []const Color, firstcolor: i32) !void {
        try errify(c.SDL_SetPaletteColors(self.ptr, @ptrCast(colors.ptr), firstcolor, @intCast(colors.len)));
    }

    /// Free a palette created with create().
    pub inline fn destroy(self: *const Palette) void {
        c.SDL_DestroyPalette(self.ptr);
    }
};

pub const PixelFormatDetails = struct {
    ptr: *const c.SDL_PixelFormatDetails,

    /// Convert one of the enumerated pixel formats to a bpp value and RGBA masks.
    pub inline fn getMasks(format: PixelFormat, bpp: *i32, rmask: *u32, gmask: *u32, bmask: *u32, amask: *u32) !void {
        try errify(c.SDL_GetMasksForPixelFormat(@intFromEnum(format), bpp, rmask, gmask, bmask, amask));
    }

    /// Convert a bpp value and RGBA masks to an enumerated pixel format.
    pub inline fn getFormatForMasks(bpp: i32, rmask: u32, gmask: u32, bmask: u32, amask: u32) PixelFormat {
        return @enumFromInt(c.SDL_GetPixelFormatForMasks(bpp, rmask, gmask, bmask, amask));
    }

    /// Create an SDL_PixelFormatDetails structure corresponding to a pixel format.
    pub inline fn getDetails(format: PixelFormat) !PixelFormatDetails {
        const details = c.SDL_GetPixelFormatDetails(@intFromEnum(format));
        try errify(details != null);
        return .{
            .ptr = details,
        };
    }

    /// Map an RGB triple to an opaque pixel value for a given pixel format.
    pub inline fn mapRGB(self: *const PixelFormatDetails, palette: *const Palette, r: u8, g: u8, b: u8) u32 {
        return c.SDL_MapRGB(self.ptr, palette.ptr, r, g, b);
    }

    /// Map an RGBA quadruple to a pixel value for a given pixel format.
    pub inline fn mapRGBA(self: *const PixelFormatDetails, palette: *const Palette, r: u8, g: u8, b: u8, a: u8) u32 {
        return c.SDL_MapRGBA(self.ptr, palette.ptr, r, g, b, a);
    }

    /// Get RGB values from a pixel in the specified format.
    pub inline fn getRGB(self: *const PixelFormatDetails, pixel: u32, palette: *const Palette, r: ?*u8, g: ?*u8, b: ?*u8) void {
        c.SDL_GetRGB(pixel, self.ptr, palette.ptr, r, g, b);
    }

    /// Get RGBA values from a pixel in the specified format.
    pub inline fn getRGBA(self: *const PixelFormatDetails, pixel: u32, palette: *const Palette, r: ?*u8, g: ?*u8, b: ?*u8, a: ?*u8) void {
        c.SDL_GetRGBA(pixel, self.ptr, palette.ptr, r, g, b, a);
    }
};

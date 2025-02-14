const std = @import("std");

const c = @import("c.zig").c;
pub const DisplayID = c.SDL_DisplayID;
pub const PropertiesID = c.SDL_PropertiesID;
pub const DisplayMode = c.SDL_DisplayMode;
pub const WindowID = c.SDL_WindowID;
const internal = @import("internal.zig");
const errify = internal.errify;
const pixels = @import("pixels.zig");
const PixelFormat = pixels.PixelFormat;
const rect = @import("rect.zig");
const Rectangle = rect.Rectangle;
const Point = rect.Point;
const Dimension = rect.Dimension;
const AspectRatio = rect.AspectRatio;
const BordersSize = rect.BordersSize;

pub fn getNumVideoDrivers() comptime_int {
    return c.SDL_GetNumVideoDrivers();
}

pub fn getVideoDriver(index: comptime_int) []const u8 {
    return std.mem.sliceTo(c.SDL_GetVideoDriver(index), 0);
}

pub fn getCurrentVideoDriver() []const u8 {
    return std.mem.sliceTo(c.SDL_GetCurrentVideoDriver(), 0);
}

pub const SystemTheme = enum(c_int) {
    unknown = c.SDL_SYSTEM_THEME_UNKNOWN,
    light = c.SDL_SYSTEM_THEME_LIGHT,
    dark = c.SDL_SYSTEM_THEME_DARK,
};

pub fn getSystemTheme() SystemTheme {
    return @enumFromInt(c.SDL_GetSystemTheme());
}

pub const DisplayProperty = union(enum) {
    hdr_enabled: bool,
    kmsdrm_panel_orientation: c_int,

    pub fn toString(property: DisplayProperty) [:0]const u8 {
        return switch (property) {
            .hdr_enabled_boolean => c.SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN,
            .kmsdrm_panel_orientation_number => c.SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER,
        };
    }
};

pub const DisplayOrientation = enum(c_uint) {
    unknown = c.SDL_ORIENTATION_UNKNOWN,
    landscape = c.SDL_ORIENTATION_LANDSCAPE,
    landscape_flipped = c.SDL_ORIENTATION_LANDSCAPE_FLIPPED,
    portrait = c.SDL_ORIENTATION_PORTRAIT,
    portrait_flipped = c.SDL_ORIENTATION_PORTRAIT_FLIPPED,
};

pub const Display = packed struct {
    id: DisplayID,

    pub fn getForPoint(point: *const Dimension) !Display {
        return .{
            .id = try errify(c.SDL_GetDisplayForPoint(@ptrCast(point))),
        };
    }

    pub fn getForRect(rectangle: *const Rectangle) !Display {
        return .{
            .id = try errify(c.SDL_GetDisplayForRect(@ptrCast(rectangle))),
        };
    }

    pub fn getForWindow(window: *const Window) !Display {
        return .{
            .id = try errify(c.SDL_GetDisplayForWindow(window.ptr)),
        };
    }

    pub fn getProperties(self: *const Display) !PropertiesID {
        return try errify(c.SDL_GetDisplayProperties(self.id));
    }

    pub fn getName(self: *const Display) []const u8 {
        return std.mem.sliceTo(c.SDL_GetDisplayName(self.id), 0);
    }

    pub fn getBounds(self: *const Display) !Rectangle {
        var bounds: Rectangle = undefined;
        try errify(c.SDL_GetDisplayBounds(self.id, @ptrCast(&bounds)));
        return bounds;
    }

    pub fn getUsableBounds(self: *const Display) !Rectangle {
        var bounds: Rectangle = undefined;
        try errify(c.SDL_GetDisplayUsableBounds(self.id, @ptrCast(&bounds)));
        return bounds;
    }

    pub fn getNaturalOrientation(self: *const Display) DisplayOrientation {
        return @enumFromInt(c.SDL_GetNaturalDisplayOrientation(self.id));
    }

    pub fn getCurrentOrientation(self: *const Display) DisplayOrientation {
        return @enumFromInt(c.SDL_GetCurrentDisplayOrientation(self.id));
    }

    pub fn getContentScale(self: *const Display) f32 {
        const scale = c.SDL_GetDisplayContentScale(self.id);
        try errify(scale != 0.0);
        return scale;
    }

    // pub fn getFullscreenDisplayModes(self: *const Display) ![]DisplayMode { //FIXME
    //     var count: c_int = undefined;
    //     var display_modes_ptr = try errify(c.SDL_GetFullscreenDisplayModes(self.id, &count));
    //     const modes = display_modes_ptr[0..@intCast(count)];
    //     return @ptrCast(modes[0..@intCast(count)]);
    // }

    pub fn getClosestFullscreenDisplayMode(
        self: *const Display,
        dimension: Dimension,
        refresh_rate: f32,
        include_high_density_modes: bool,
    ) !DisplayMode {
        var closest: DisplayMode = undefined;
        try errify(c.SDL_GetClosestFullscreenDisplayMode(
            self.id,
            dimension.w,
            dimension.h,
            refresh_rate,
            include_high_density_modes,
            &closest,
        ));
        return closest;
    }

    pub fn getDesktopDisplayMode(self: *const Display) !DisplayMode {
        const display_mode_ptr = try errify(c.SDL_GetDesktopDisplayMode(self.id));
        const display_mode = display_mode_ptr.*;
        return display_mode;
    }

    pub fn getCurrentDisplayMode(self: *const Display) DisplayMode {
        return (try errify(c.SDL_GetCurrentDisplayMode(self.id))).*;
    }
};

pub fn getDisplays() ![]Display {
    var count: c_int = undefined;
    var display_ids = try errify(c.SDL_GetDisplays(&count));
    return @ptrCast(display_ids[0..@intCast(count)]);
}

pub fn getPrimaryDisplay() !Display {
    const display_id = try errify(c.SDL_GetPrimaryDisplay());
    return .{
        .id = display_id,
    };
}

pub const WindowFlags = packed struct {
    fullscreen: bool = false,
    opengl: bool = false,
    occluded: bool = false,
    hidden: bool = false,
    borderless: bool = false,
    resizable: bool = false,
    minimized: bool = false,
    maximized: bool = false,
    mouse_grabbed: bool = false,
    input_focus: bool = false,
    mouse_focus: bool = false,
    external: bool = false,
    modal: bool = false,
    high_pixel_density: bool = false,
    mouse_capture: bool = false,
    mouse_relative_mode: bool = false,
    always_on_top: bool = false,
    utility: bool = false,
    tooltip: bool = false,
    popup_menu: bool = false,
    keyboard_grabbed: bool = false,
    vulkan: bool = false,
    metal: bool = false,
    transparent: bool = false,
    not_focusable: bool = false,

    pub fn toInt(self: *const WindowFlags) c.SDL_WindowFlags {
        return (if (self.fullscreen) c.SDL_WINDOW_FULLSCREEN else 0) |
            (if (self.opengl) c.SDL_WINDOW_OPENGL else 0) |
            (if (self.occluded) c.SDL_WINDOW_OCCLUDED else 0) |
            (if (self.hidden) c.SDL_WINDOW_HIDDEN else 0) |
            (if (self.borderless) c.SDL_WINDOW_BORDERLESS else 0) |
            (if (self.resizable) c.SDL_WINDOW_RESIZABLE else 0) |
            (if (self.minimized) c.SDL_WINDOW_MINIMIZED else 0) |
            (if (self.maximized) c.SDL_WINDOW_MAXIMIZED else 0) |
            (if (self.mouse_grabbed) c.SDL_WINDOW_MOUSE_GRABBED else 0) |
            (if (self.input_focus) c.SDL_WINDOW_INPUT_FOCUS else 0) |
            (if (self.mouse_focus) c.SDL_WINDOW_MOUSE_FOCUS else 0) |
            (if (self.external) c.SDL_WINDOW_EXTERNAL else 0) |
            (if (self.modal) c.SDL_WINDOW_MODAL else 0) |
            (if (self.high_pixel_density) c.SDL_WINDOW_HIGH_PIXEL_DENSITY else 0) |
            (if (self.mouse_capture) c.SDL_WINDOW_MOUSE_CAPTURE else 0) |
            (if (self.mouse_relative_mode) c.SDL_WINDOW_MOUSE_RELATIVE_MODE else 0) |
            (if (self.always_on_top) c.SDL_WINDOW_ALWAYS_ON_TOP else 0) |
            (if (self.utility) c.SDL_WINDOW_UTILITY else 0) |
            (if (self.tooltip) c.SDL_WINDOW_TOOLTIP else 0) |
            (if (self.popup_menu) c.SDL_WINDOW_POPUP_MENU else 0) |
            (if (self.keyboard_grabbed) c.SDL_WINDOW_KEYBOARD_GRABBED else 0) |
            (if (self.vulkan) c.SDL_WINDOW_VULKAN else 0) |
            (if (self.metal) c.SDL_WINDOW_METAL else 0) |
            (if (self.transparent) c.SDL_WINDOW_TRANSPARENT else 0) |
            (if (self.not_focusable) c.SDL_WINDOW_NOT_FOCUSABLE else 0);
    }

    pub fn fromInt(flags: c.SDL_WindowFlags) WindowFlags {
        return .{
            .opengl = flags & c.SDL_WINDOW_OPENGL != 0,
            .occluded = flags & c.SDL_WINDOW_OCCLUDED != 0,
            .hidden = flags & c.SDL_WINDOW_HIDDEN != 0,
            .borderless = flags & c.SDL_WINDOW_BORDERLESS != 0,
            .resizable = flags & c.SDL_WINDOW_RESIZABLE != 0,
            .minimized = flags & c.SDL_WINDOW_MINIMIZED != 0,
            .maximized = flags & c.SDL_WINDOW_MAXIMIZED != 0,
            .mouse_grabbed = flags & c.SDL_WINDOW_MOUSE_GRABBED != 0,
            .input_focus = flags & c.SDL_WINDOW_INPUT_FOCUS != 0,
            .mouse_focus = flags & c.SDL_WINDOW_MOUSE_FOCUS != 0,
            .external = flags & c.SDL_WINDOW_EXTERNAL != 0,
            .modal = flags & c.SDL_WINDOW_MODAL != 0,
            .high_pixel_density = flags & c.SDL_WINDOW_HIGH_PIXEL_DENSITY != 0,
            .mouse_capture = flags & c.SDL_WINDOW_MOUSE_CAPTURE != 0,
            .mouse_relative_mode = flags & c.SDL_WINDOW_MOUSE_RELATIVE_MODE != 0,
            .always_on_top = flags & c.SDL_WINDOW_ALWAYS_ON_TOP != 0,
            .utility = flags & c.SDL_WINDOW_UTILITY != 0,
            .tooltip = flags & c.SDL_WINDOW_TOOLTIP != 0,
            .popup_menu = flags & c.SDL_WINDOW_POPUP_MENU != 0,
            .keyboard_grabbed = flags & c.SDL_WINDOW_KEYBOARD_GRABBED != 0,
            .vulkan = flags & c.SDL_WINDOW_VULKAN != 0,
            .metal = flags & c.SDL_WINDOW_METAL != 0,
            .transparent = flags & c.SDL_WINDOW_TRANSPARENT != 0,
            .not_focusable = flags & c.SDL_WINDOW_NOT_FOCUSABLE != 0,
        };
    }
};

pub const Window = struct {
    ptr: *c.SDL_Window,

    pub fn create(
        title: [:0]const u8,
        width: comptime_int,
        height: comptime_int,
        flags: WindowFlags,
    ) !Window {
        return .{
            .ptr = try errify(c.SDL_CreateWindow(
                title.ptr,
                width,
                height,
                flags.toInt(),
            )),
        };
    }

    pub fn createWithProperties(props: PropertiesID) !Window { // FIXME fix propertiesid
        return .{
            .ptr = try errify(c.SDL_CreateWindowWithProperties(props)),
        };
    }

    pub fn destroy(self: *const Window) void {
        c.SDL_DestroyWindow(self.ptr);
    }

    pub fn getPixelDensity(self: *const Window) !f32 {
        return try errify(c.SDL_GetWindowPixelDensity(self.ptr));
    }

    pub fn getDisplayScale(self: *const Window) !f32 {
        return try errify(c.SDL_GetWindowDisplayScale(self.ptr));
    }

    pub fn setFullscreenMode(self: *const Window, mode: *const DisplayMode) !void {
        try errify(c.SDL_SetWindowFullscreenMode(self.ptr, mode));
    }

    pub fn getFullscreenMode(self: *const Window) !DisplayMode {
        return (try errify(c.SDL_GetWindowFullscreenMode(self.ptr))).*;
    }

    pub fn getICCProfile(self: *const Window, size: *usize) !*anyopaque {
        return try errify(c.SDL_GetWindowICCProfile(self.ptr, size));
    }

    pub fn getPixelFormat(self: *const Window) !PixelFormat {
        const pixel_format: PixelFormat = @enumFromInt(c.SDL_GetWindowPixelFormat(self.ptr));
        try errify(pixel_format != .unknown);
        return pixel_format;
    }

    pub fn createPopup(
        parent: *const Window,
        offset_x: i32,
        offset_y: i32,
        dimension: Dimension,
        flags: WindowFlags,
    ) !Window {
        return .{
            .ptr = try errify(c.SDL_CreatePopupWindow(parent.ptr, offset_x, offset_y, dimension.w, dimension.h, flags.toInt())),
        };
    }

    pub fn getID(self: *const Window) !WindowID {
        return try errify(c.SDL_GetWindowID(self.ptr));
    }

    pub fn getFromID(id: WindowID) !Window {
        return .{
            .ptr = try errify(c.SDL_GetWindowFromID(id)),
        };
    }

    pub fn getParent(self: *const Window) !Window {
        return .{
            .ptr = try errify(c.SDL_GetWindowParent(self.ptr)),
        };
    }

    pub fn getProperties(self: *const Window) !PropertiesID {
        return try errify(c.SDL_GetWindowProperties(self.ptr));
    }

    pub fn getFlags(self: *const Window) WindowFlags {
        return WindowFlags.fromInt(c.SDL_GetWindowFlags(self.ptr));
    }

    pub fn setTitle(self: *const Window, title: [:0]const u8) !void {
        try errify(c.SDL_SetWindowTitle(self.ptr, title));
    }

    pub fn getTitle(self: *const Window) []const u8 {
        return std.mem.sliceTo(c.SDL_GetWindowTitle(self.ptr), 0);
    }

    //   pub fn setIcon(self: *const Window, SDL_Surface *icon)!void{} //FIXME

    pub fn setPosition(self: *const Window, point: Point) !void {
        try errify(c.SDL_SetWindowPosition(self.ptr, point.x, point.y));
    }

    pub fn getPosition(self: *const Window) !Point {
        var point: Dimension = undefined;
        try errify(c.SDL_GetWindowPosition(self.ptr, &point.x, &point.y));
        return point;
    }

    pub fn setSize(self: *const Window, dimension: Dimension) !void {
        try errify(c.SDL_SetWindowSize(self.ptr, dimension.w, dimension.h));
    }

    pub fn getSize(self: *const Window) !Dimension {
        var dimension: Dimension = undefined;
        try errify(c.SDL_GetWindowSize(self.ptr, &dimension.w, &dimension.h));
        return dimension;
    }

    pub fn getSafeArea(self: *const Window) !Rectangle {
        var rectangle: Rectangle = undefined;
        try errify(c.SDL_GetWindowSafeArea(self.ptr, @ptrCast(&rectangle)));
        return rectangle;
    }

    pub fn setAspectRatio(self: *const Window, aspect_ratio: AspectRatio) !void {
        try errify(c.SDL_SetWindowAspectRatio(self.ptr, aspect_ratio.min_aspect, aspect_ratio.max_aspect));
    }

    pub fn getAspectRatio(self: *const Window) !AspectRatio {
        var aspect_ratio: AspectRatio = undefined;
        try errify(c.SDL_GetWindowAspectRatio(self.ptr, @ptrCast(&aspect_ratio)));
        return aspect_ratio;
    }

    pub fn getBordersSize(self: *const Window) !BordersSize {
        var borders_size: BordersSize = undefined;
        try errify(c.SDL_GetWindowBordersSize(
            self.ptr,
            &borders_size.top,
            &borders_size.left,
            &borders_size.bottom,
            &borders_size.right,
        ));
        return borders_size;
    }

    pub fn getSizeInPixels(self: *const Window) !Dimension {
        var dimension: Dimension = undefined;
        try errify(c.SDL_GetWindowSizeInPixels(self.ptr, &dimension.w, &dimension.h));
        return dimension;
    }

    pub fn setMinimumSize(self: *const Window, min_dimension: Dimension) !void {
        try errify(c.SDL_SetWindowMinimumSize(self.ptr, min_dimension.w, min_dimension.h));
    }

    pub fn getMinimumSize(self: *const Window) !Dimension {
        var dimension: Dimension = undefined;
        try errify(c.SDL_GetWindowMinimumSize(self.ptr, &dimension.w, &dimension.h));
        return dimension;
    }

    pub fn setMaximumSize(self: *const Window, max_dimension: Dimension) !void {
        try errify(c.SDL_SetWindowMaximumSize(self.ptr, max_dimension.w, max_dimension.h));
    }

    pub fn getMaximumSize(self: *const Window) !Dimension {
        var dimension: Dimension = undefined;
        try errify(c.SDL_GetWindowMaximumSize(self.ptr, &dimension.w, &dimension.h));
        return dimension;
    }

    pub fn setBordered(self: *const Window, bordered: bool) !void {
        try errify(c.SDL_SetWindowBordered(self.ptr, bordered));
    }

    pub fn setResizable(self: *const Window, resizable: bool) !void {
        try errify(c.SDL_SetWindowResizable(self.ptr, resizable));
    }

    pub fn setAlwaysOnTop(self: *const Window, on_top: bool) !void {
        try errify(c.SDL_SetWindowAlwaysOnTop(self.ptr, on_top));
    }

    pub fn show(self: *const Window) !void {
        try errify(c.SDL_ShowWindow(self.ptr));
    }

    pub fn hide(self: *const Window) !void {
        try errify(c.SDL_HideWindow(self.ptr));
    }

    pub fn raise(self: *const Window) !void {
        try errify(c.SDL_RaiseWindow(self.ptr));
    }

    pub fn maximize(self: *const Window) !void {
        try errify(c.SDL_MaximizeWindow(self.ptr));
    }

    pub fn minimize(self: *const Window) !void {
        try errify(c.SDL_MinimizeWindow(self.ptr));
    }

    pub fn restore(self: *const Window) !void {
        try errify(c.SDL_RestoreWindow(self.ptr));
    }

    pub fn setFullscreen(self: *const Window, fullscreen: bool) !void {
        try errify(c.SDL_SetWindowFullscreen(self.ptr, fullscreen));
    }

    pub fn sync(self: *const Window) !void {
        try errify(c.SDL_SyncWindow(self.ptr));
    }

    pub fn hasSurface(self: *const Window) bool {
        return c.SDL_WindowHasSurface(self.ptr);
    }

    //  pub fn surface * SDL_GetWindowSurface(self: *const Window)with{} // FIXME

    pub fn setSurfaceVSync(self: *const Window, vsync: c_int) !void {
        try errify(c.SDL_SetWindowSurfaceVSync(self.ptr, vsync));
    }

    pub fn getSurfaceVSync(self: *const Window) !c_int {
        var vsync: c_int = undefined;
        try errify(c.SDL_GetWindowSurfaceVSync(self.ptr, &vsync));
        return vsync;
    }

    pub fn updateSurface(self: *const Window) !void {
        try errify(c.SDL_UpdateWindowSurface(self.ptr));
    }

    pub fn updateSurfaceRects(self: *const Window, rects: []const Rectangle) !void {
        try errify(c.SDL_UpdateWindowSurfaceRects(self.ptr, @ptrCast(rects.ptr), @intCast(rects.len)));
    }

    pub fn destroySurface(self: *const Window) !void {
        try errify(c.SDL_DestroyWindowSurface(self.ptr));
    }

    pub fn setKeyboardGrab(self: *const Window, grabbed: bool) !void {
        try errify(c.SDL_SetWindowKeyboardGrab(self.ptr, grabbed));
    }

    pub fn setMouseGrab(self: *const Window, grabbed: bool) !void {
        try errify(c.SDL_SetWindowMouseGrab(self.ptr, grabbed));
    }

    pub fn getKeyboardGrab(self: *const Window) bool {
        return c.SDL_GetWindowKeyboardGrab(self.ptr);
    }

    pub fn getMouseGrab(self: *const Window) !void {
        return c.SDL_GetWindowMouseGrab(self.ptr);
    }

    pub fn getGrabbedWindow() ?Window {
        if (c.SDL_GetGrabbedWindow()) |ptr| {
            return .{
                .ptr = ptr,
            };
        }
        return null;
    }

    pub fn setMouseRect(self: *const Window, rectangle: Rectangle) !void {
        try errify(c.SDL_SetWindowMouseRect(self.ptr, @ptrCast(&rectangle)));
    }

    pub fn getMouseRect(self: *const Window) ?Rectangle {
        if (c.SDL_GetWindowMouseRect(self.ptr)) |ptr| {
            return ptr.*;
        }
        return null;
    }

    pub fn setOpacity(self: *const Window, opacity: f32) !void {
        try errify(c.SDL_SetWindowOpacity(self.ptr, opacity));
    }

    pub fn getOpacity(self: *const Window) !f32 {
        const opacity = c.SDL_GetWindowOpacity(self.ptr);
        try errify(opacity != -1);
        return opacity;
    }

    pub fn setParent(self: *const Window, parent: Window) !void {
        try errify(c.SDL_SetWindowParent(self.ptr, parent.ptr));
    }

    pub fn setModal(self: *const Window, modal: bool) !void {
        try errify(c.SDL_SetWindowModal(self.ptr, modal));
    }

    pub fn setFocusable(self: *const Window, focusable: bool) !void {
        try errify(c.SDL_SetWindowFocusable(self.ptr, focusable));
    }

    pub fn showSystemMenu(self: *const Window, point: Point) !void {
        try errify(c.SDL_ShowWindowSystemMenu(self.ptr, point.x, point.y));
    }

    //   pub fn setHitTest(self: *const Window, SDL_HitTest callback, void *callback_data)!void{} // FIXME

    //   pub fn setShape(self: *const Window, SDL_Surface *shape)!void{} // FIXME

    // SDL_flashWindow(SDL_ *window, SDL_FlashOperation operation)!void{} // FIXME
};

pub fn getWindows() ![]Window {
    var count: c_int = undefined;
    var window_ptrs = try errify(c.SDL_GetWindows(&count));
    return @ptrCast(window_ptrs[0..@intCast(count)]);
}

pub fn screenSaverEnabled() bool {
    return c.SDL_ScreenSaverEnabled();
}

pub fn enableScreenSaver() !void {
    try errify(c.SDL_EnableScreenSaver());
}

pub fn disableScreenSaver() !void {
    try errify(c.SDL_DisableScreenSaver());
}

pub const GLattr = enum(c_int) {
    red_size = c.SDL_GL_RED_SIZE,
    green_size = c.SDL_GL_GREEN_SIZE,
    blue_size = c.SDL_GL_BLUE_SIZE,
    alpha_size = c.SDL_GL_ALPHA_SIZE,
    buffer_size = c.SDL_GL_BUFFER_SIZE,
    doublebuffer = c.SDL_GL_DOUBLEBUFFER,
    depth_size = c.SDL_GL_DEPTH_SIZE,
    stencil_size = c.SDL_GL_STENCIL_SIZE,
    accum_red_size = c.SDL_GL_ACCUM_RED_SIZE,
    accum_green_size = c.SDL_GL_ACCUM_GREEN_SIZE,
    accum_blue_size = c.SDL_GL_ACCUM_BLUE_SIZE,
    accum_alpha_size = c.SDL_GL_ACCUM_ALPHA_SIZE,
    stereo = c.SDL_GL_STEREO,
    multisamplebuffers = c.SDL_GL_MULTISAMPLEBUFFERS,
    multisamplesamples = c.SDL_GL_MULTISAMPLESAMPLES,
    accelerated_visual = c.SDL_GL_ACCELERATED_VISUAL,
    retained_backing = c.SDL_GL_RETAINED_BACKING,
    context_major_version = c.SDL_GL_CONTEXT_MAJOR_VERSION,
    context_minor_version = c.SDL_GL_CONTEXT_MINOR_VERSION,
    context_flags = c.SDL_GL_CONTEXT_FLAGS,
    context_profile_mask = c.SDL_GL_CONTEXT_PROFILE_MASK,
    share_with_current_context = c.SDL_GL_SHARE_WITH_CURRENT_CONTEXT,
    framebuffer_srgb_capable = c.SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,
    context_release_behavior = c.SDL_GL_CONTEXT_RELEASE_BEHAVIOR,
    context_reset_notification = c.SDL_GL_CONTEXT_RESET_NOTIFICATION,
    context_no_error = c.SDL_GL_CONTEXT_NO_ERROR,
    floatbuffers = c.SDL_GL_FLOATBUFFERS,
    egl_platform = c.SDL_GL_EGL_PLATFORM,
};

pub const gl = struct {
    pub const GLContext = struct {
        ctx: c.SDL_GLContext,

        pub fn create(window: Window) !GLContext {
            return .{
                .ctx = try errify(c.SDL_GL_CreateContext(window.ptr)),
            };
        }

        pub fn makeCurrent(self: *const GLContext, window: Window) !void {
            try errify(c.SDL_GL_MakeCurrent(window.ptr, self.ctx));
        }

        pub fn destroy(self: *const GLContext) !void {
            try errify(c.SDL_GL_DestroyContext(self.ctx));
        }
    };

    pub fn loadLibrary(path: [*:0]const u8) !void {
        try errify(c.SDL_GL_LoadLibrary(path));
    }

    pub fn getProcAddress(proc: [*:0]const u8) ?*const anyopaque {
        return c.SDL_GL_GetProcAddress(proc);
    }

    pub fn unloadLibrary() void {
        c.SDL_GL_UnloadLibrary();
    }

    pub fn extensionSupported(extension: [*:0]const u8) bool {
        return c.SDL_GL_ExtensionSupported(extension);
    }

    pub fn resetAttributes() void {
        c.SDL_GL_ResetAttributes();
    }

    pub fn setAttribute(attr: GLattr, value: c_int) !void {
        try errify(c.SDL_GL_SetAttribute(@intFromEnum(attr), value));
    }

    pub fn getAttribute(attr: GLattr) !c_int {
        var value: c_int = undefined;
        try errify(c.SDL_GL_GetAttribute(@intFromEnum(attr), &value));
        return value;
    }

    pub fn getCurrentWindow() !Window {
        return .{
            .ptr = try errify(c.SDL_GL_GetCurrentWindow()),
        };
    }

    pub fn getCurrentContext() GLContext {
        return c.SDL_GL_GetCurrentContext();
    }

    pub fn setSwapInterval(interval: i32) !void {
        try errify(c.SDL_GL_SetSwapInterval(interval));
    }

    pub fn getSwapInterval() !c_int {
        var interval: c_int = undefined;
        try errify(c.SDL_GL_GetSwapInterval(&interval));
        return interval;
    }

    pub fn swapWindow(window: Window) !void {
        try errify(c.SDL_GL_SwapWindow(window));
    }
};

pub const egl = struct {
    pub const EGLDisplay = c.SDL_EGLDisplay;
    pub const EGLConfig = c.SDL_EGLConfig;
    pub const EGLSurface = c.SDL_EGLSurface;
    pub const EGLAttribArrayCallback = c.SDL_EGLAttribArrayCallback;
    pub const EGLIntArrayCallback = c.SDL_EGLIntArrayCallback;

    pub fn getProcAddress(proc: [*:0]const u8) ?c.SDL_FunctionPointer {
        return c.SDL_EGL_GetProcAddress(proc);
    }

    pub fn getCurrentDisplay() !EGLDisplay {
        return try errify(c.SDL_EGL_GetCurrentDisplay());
    }

    pub fn getCurrentConfig() !EGLConfig {
        return try errify(c.SDL_EGL_GetCurrentConfig());
    }

    pub fn getWindowSurface(window: Window) !EGLSurface {
        return try errify(c.SDL_EGL_GetWindowSurface(window.ptr));
    }

    pub fn setAttributeCallbacks(
        platform_attrib_callback: EGLAttribArrayCallback,
        surface_attrib_callback: EGLIntArrayCallback,
        context_attrib_callback: EGLIntArrayCallback,
        userdata: ?*anyopaque,
    ) void {
        c.SDL_EGL_SetAttributeCallbacks(
            platform_attrib_callback,
            surface_attrib_callback,
            context_attrib_callback,
            userdata,
        );
    }
};

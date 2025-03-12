const std = @import("std");

const c = @import("c.zig").c;
pub const DisplayID = c.SDL_DisplayID;
pub const PropertiesID = c.SDL_PropertiesID;
pub const DisplayMode = c.SDL_DisplayMode;
pub const WindowID = c.SDL_WindowID;
const internal = @import("internal.zig");
const errify = internal.errify;
const errifyWithValue = internal.errifyWithValue;
const pixels = @import("pixels.zig");
const PixelFormat = pixels.PixelFormat;
const rect = @import("rect.zig");
const Rect = rect.Rect;
const Point = rect.Point;
const Size = rect.Size;
const AspectRatio = rect.AspectRatio;
const BordersSize = rect.BordersSize;
const Surface = @import("surface.zig").Surface;

pub const WindowProperties = struct {
    always_on_top: ?bool = null,
    borderless: ?bool = null,
    focusable: ?bool = null,
    external_graphics_context: ?bool = null,
    flags: ?u32 = null,
    fullscreen: ?bool = null,
    height: ?i32 = null,
    hidden: ?bool = null,
    high_pixel_density: ?bool = null,
    maximized: ?bool = null,
    menu: ?bool = null,
    metal: ?bool = null,
    minimized: ?bool = null,
    modal: ?bool = null,
    mouse_grabbed: ?bool = null,
    opengl: ?bool = null,
    parent: ?*anyopaque = null,
    resizable: ?bool = null,
    title: ?[*:0]const u8 = null,
    transparent: ?bool = null,
    tooltip: ?bool = null,
    utility: ?bool = null,
    vulkan: ?bool = null,
    width: ?i32 = null,
    x: ?i32 = null,
    y: ?i32 = null,
    cocoa_window: ?*anyopaque = null,
    cocoa_view: ?*anyopaque = null,
    wayland_surface_role_custom: ?bool = null,
    wayland_create_egl_window: ?bool = null,
    wayland_wl_surface: ?*anyopaque = null,
    win32_hwnd: ?*anyopaque = null,
    win32_pixel_format_hwnd: ?*anyopaque = null,
    x11_window: ?u32 = null,

    pub inline fn apply(self: WindowProperties, props: c.SDL_PropertiesID) void {
        if (self.always_on_top) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN, v);
        if (self.borderless) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN, v);
        if (self.focusable) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN, v);
        if (self.external_graphics_context) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN, v);
        if (self.flags) |v| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER, v);
        if (self.fullscreen) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN, v);
        if (self.height) |v| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER, v);
        if (self.hidden) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN, v);
        if (self.high_pixel_density) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN, v);
        if (self.maximized) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN, v);
        if (self.menu) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN, v);
        if (self.metal) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN, v);
        if (self.minimized) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN, v);
        if (self.modal) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN, v);
        if (self.mouse_grabbed) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN, v);
        if (self.opengl) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN, v);
        if (self.parent) |v| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_WINDOW_CREATE_PARENT_POINTER, v);
        if (self.resizable) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN, v);
        if (self.title) |v| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_WINDOW_CREATE_TITLE_STRING, v);
        if (self.transparent) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN, v);
        if (self.tooltip) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN, v);
        if (self.utility) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN, v);
        if (self.vulkan) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN, v);
        if (self.width) |v| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER, v);
        if (self.x) |v| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_X_NUMBER, v);
        if (self.y) |v| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_Y_NUMBER, v);
        if (self.cocoa_window) |v| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER, v);
        if (self.cocoa_view) |v| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER, v);
        if (self.wayland_surface_role_custom) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN, v);
        if (self.wayland_create_egl_window) |v| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN, v);
        if (self.wayland_wl_surface) |v| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER, v);
        if (self.win32_hwnd) |v| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER, v);
        if (self.win32_pixel_format_hwnd) |v| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER, v);
        if (self.x11_window) |v| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER, v);
    }
};

/// Get the number of video drivers compiled into SDL.
pub inline fn getNumVideoDrivers() c_int {
    return c.SDL_GetNumVideoDrivers();
}

/// Get the name of a built in video driver.
pub inline fn getVideoDriver(index: comptime_int) []const u8 {
    return std.mem.span(c.SDL_GetVideoDriver(index));
}

/// Get the name of the currently initialized video driver.
pub inline fn getCurrentVideoDriver() []const u8 {
    return std.mem.span(c.SDL_GetCurrentVideoDriver());
}

pub const SystemTheme = enum(u32) {
    unknown = c.SDL_SYSTEM_THEME_UNKNOWN,
    light = c.SDL_SYSTEM_THEME_LIGHT,
    dark = c.SDL_SYSTEM_THEME_DARK,
};

/// Get the current system theme.
pub inline fn getSystemTheme() SystemTheme {
    return @enumFromInt(c.SDL_GetSystemTheme());
}

pub const DisplayProperty = union(enum) {
    hdr_enabled: bool,
    kmsdrm_panel_orientation: c_int,

    pub inline fn toString(property: DisplayProperty) [:0]const u8 {
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

    /// Get the display containing a point.
    pub inline fn getForPoint(point: Point) !Display {
        return .{
            .id = try errify(c.SDL_GetDisplayForPoint(@ptrCast(&point))),
        };
    }

    /// Get the display primarily containing a rect.
    pub inline fn getForRect(rectangle: Rect) !Display {
        return .{
            .id = try errify(c.SDL_GetDisplayForRect(@ptrCast(&rectangle))),
        };
    }

    /// Get the display associated with a window.
    pub inline fn getForWindow(window: Window) !Display {
        return .{
            .id = try errify(c.SDL_GetDisplayForWindow(window.ptr)),
        };
    }

    /// Get the properties associated with a display.
    pub inline fn getProperties(self: *const Display) !PropertiesID {
        return try errify(c.SDL_GetDisplayProperties(self.id));
    }

    /// Get the name of a display in UTF-8 encoding.
    pub inline fn getName(self: *const Display) []const u8 {
        return std.mem.span(c.SDL_GetDisplayName(self.id));
    }

    /// Get the desktop area represented by a display.
    pub inline fn getBounds(self: *const Display) !Rect {
        var bounds: Rect = undefined;
        try errify(c.SDL_GetDisplayBounds(self.id, @ptrCast(&bounds)));
        return bounds;
    }

    /// Get the usable desktop area represented by a display, in screen coordinates.
    pub inline fn getUsableBounds(self: *const Display) !Rect {
        var bounds: Rect = undefined;
        try errify(c.SDL_GetDisplayUsableBounds(self.id, @ptrCast(&bounds)));
        return bounds;
    }

    /// Get the orientation of a display when it is unrotated.
    pub inline fn getNaturalOrientation(self: *const Display) DisplayOrientation {
        return @enumFromInt(c.SDL_GetNaturalDisplayOrientation(self.id));
    }

    /// Get the orientation of a display.
    pub inline fn getCurrentOrientation(self: *const Display) DisplayOrientation {
        return @enumFromInt(c.SDL_GetCurrentDisplayOrientation(self.id));
    }

    /// Get the content scale of a display.
    pub inline fn getContentScale(self: *const Display) !f32 {
        return try errify(c.SDL_GetDisplayContentScale(self.id));
    }

    /// Get a list of fullscreen display modes available on a display.
    pub inline fn getFullscreenDisplayModes(self: *const Display) ![]const DisplayMode {
        var count: c_int = undefined;
        const display_modes_ptr = try errify(c.SDL_GetFullscreenDisplayModes(self.id, &count));
        return @as([*]const DisplayMode, @ptrCast(display_modes_ptr))[0..@intCast(count)];
    }

    ///  Get the closest match to the requested display mode.
    pub inline fn getClosestFullscreenDisplayMode(
        self: *const Display,
        size: Size,
        refresh_rate: f32,
        include_high_density_modes: bool,
    ) !DisplayMode {
        var closest: DisplayMode = undefined;
        try errify(c.SDL_GetClosestFullscreenDisplayMode(
            self.id,
            size.width,
            size.height,
            refresh_rate,
            include_high_density_modes,
            &closest,
        ));
        return closest;
    }

    /// Get information about the desktop's display mode.
    pub inline fn getDesktopDisplayMode(self: *const Display) !DisplayMode {
        const display_mode_ptr = try errify(c.SDL_GetDesktopDisplayMode(self.id));
        const display_mode = display_mode_ptr.*;
        return display_mode;
    }

    /// Get information about the current display mode.
    pub inline fn getCurrentDisplayMode(self: *const Display) !DisplayMode {
        return (try errify(c.SDL_GetCurrentDisplayMode(self.id))).*;
    }
};

/// Get a list of currently connected displays.
pub inline fn getDisplays() ![]Display {
    var count: c_int = undefined;
    var display_ids = try errify(c.SDL_GetDisplays(&count));
    return @ptrCast(display_ids[0..@intCast(count)]);
}

/// Return the primary display.
pub inline fn getPrimaryDisplay() !Display {
    return .{
        .id = try errify(c.SDL_GetPrimaryDisplay()),
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

    pub inline fn toInt(self: *const WindowFlags) c.SDL_WindowFlags {
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

    pub inline fn fromInt(flags: c.SDL_WindowFlags) WindowFlags {
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

/// Get the window that currently has an input grab enabled.
pub inline fn getGrabbedWindow() ?Window {
    return if (c.SDL_GetGrabbedWindow()) |window| .{ .ptr = window } else null;
}

pub const Window = struct {
    ptr: *c.SDL_Window,

    /// Create a window with the specified sizes and flags.
    pub inline fn create(
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

    /// Create a window with the specified properties.
    pub inline fn createWithProperties(props: WindowProperties) !Window {
        const properties = c.SDL_CreateProperties();
        defer c.SDL_DestroyProperties(properties);
        props.apply(properties);
        const window = try errify(c.SDL_CreateWindowWithProperties(properties));
        return Window{
            .ptr = window,
        };
    }

    /// Destroy a window.
    pub inline fn destroy(self: *const Window) void {
        c.SDL_DestroyWindow(self.ptr);
    }

    /// Get the pixel density of a window.
    pub inline fn getPixelDensity(self: *const Window) !f32 {
        return try errify(c.SDL_GetWindowPixelDensity(self.ptr));
    }

    /// Get the content display scale relative to a window's pixel size.
    pub inline fn getDisplayScale(self: *const Window) !f32 {
        return try errify(c.SDL_GetWindowDisplayScale(self.ptr));
    }

    /// Set the display mode to use when a window is visible and fullscreen.
    pub inline fn setFullscreenMode(self: *const Window, mode: *const DisplayMode) !void {
        try errify(c.SDL_SetWindowFullscreenMode(self.ptr, mode));
    }

    /// Query the display mode to use when a window is visible at fullscreen.
    pub inline fn getFullscreenMode(self: *const Window) !DisplayMode {
        return (try errify(c.SDL_GetWindowFullscreenMode(self.ptr))).*;
    }

    /// Get the raw ICC profile data for the screen the window is currently on.
    pub inline fn getICCProfile(self: *const Window, size: *usize) !*anyopaque {
        return try errify(c.SDL_GetWindowICCProfile(self.ptr, size));
    }

    /// Get the pixel format associated with the window.
    pub inline fn getPixelFormat(self: *const Window) !PixelFormat {
        return @enumFromInt(try errifyWithValue(
            c.SDL_GetWindowPixelFormat(self.ptr),
            c.SDL_PIXELFORMAT_UNKNOWN,
        ));
    }

    /// Create a child popup window of the specified parent window.
    pub inline fn createPopup(
        parent: *const Window,
        offset_x: i32,
        offset_y: i32,
        size: Size,
        flags: WindowFlags,
    ) !Window {
        return .{
            .ptr = try errify(c.SDL_CreatePopupWindow(parent.ptr, offset_x, offset_y, size.width, size.height, flags.toInt())),
        };
    }

    /// Get the numeric ID of a window.
    pub inline fn getID(self: *const Window) !WindowID {
        return try errify(c.SDL_GetWindowID(self.ptr));
    }

    /// Get a window from a stored ID.
    pub inline fn getFromID(id: WindowID) !Window {
        return .{
            .ptr = try errify(c.SDL_GetWindowFromID(id)),
        };
    }

    /// Get parent of a window.
    pub inline fn getParent(self: *const Window) !Window {
        return .{
            .ptr = try errify(c.SDL_GetWindowParent(self.ptr)),
        };
    }

    /// Get the properties associated with a window.
    pub inline fn getProperties(self: *const Window) !PropertiesID {
        return try errify(c.SDL_GetWindowProperties(self.ptr));
    }

    /// Get the window flags.
    pub inline fn getFlags(self: *const Window) WindowFlags {
        return WindowFlags.fromInt(c.SDL_GetWindowFlags(self.ptr));
    }

    /// Set the title of a window.
    pub inline fn setTitle(self: *const Window, title: [:0]const u8) !void {
        try errify(c.SDL_SetWindowTitle(self.ptr, title));
    }

    /// Get the title of a window.
    pub inline fn getTitle(self: *const Window) []const u8 {
        return std.mem.span(c.SDL_GetWindowTitle(self.ptr));
    }

    /// Set the icon for a window.
    pub inline fn setIcon(self: *const Window, icon: Surface) !void {
        try errify(c.SDL_SetWindowIcon(self.ptr, icon.ptr));
    }

    /// Request that the window's position be set.
    pub inline fn setPosition(self: *const Window, point: Point) !void {
        try errify(c.SDL_SetWindowPosition(self.ptr, point.x, point.y));
    }

    /// Get the position of a window.
    pub inline fn getPosition(self: *const Window) !Point {
        var point: Point = undefined;
        try errify(c.SDL_GetWindowPosition(self.ptr, &point.x, &point.y));
        return point;
    }

    /// Request that the size of a window's client area be set.
    pub inline fn setSize(self: *const Window, size: Size) !void {
        try errify(c.SDL_SetWindowSize(self.ptr, size.width, size.height));
    }

    /// Get the size of a window's client area.
    pub inline fn getSize(self: *const Window) !Size {
        var size: Size = undefined;
        try errify(c.SDL_GetWindowSize(self.ptr, &size.width, &size.height));
        return size;
    }

    /// Get the safe area for this window.
    pub inline fn getSafeArea(self: *const Window) !Rect {
        var rectangle: Rect = undefined;
        try errify(c.SDL_GetWindowSafeArea(self.ptr, @ptrCast(&rectangle)));
        return rectangle;
    }

    /// Request that the aspect ratio of a window's client area be set.
    pub inline fn setAspectRatio(self: *const Window, aspect_ratio: AspectRatio) !void {
        try errify(c.SDL_SetWindowAspectRatio(self.ptr, aspect_ratio.min_aspect, aspect_ratio.max_aspect));
    }

    /// Get the size of a window's client area.
    pub inline fn getAspectRatio(self: *const Window) !AspectRatio {
        var aspect_ratio: AspectRatio = undefined;
        try errify(c.SDL_GetWindowAspectRatio(self.ptr, &aspect_ratio.min_aspect, &aspect_ratio.max_aspect));
        return aspect_ratio;
    }

    /// Get the size of a window's borders (decorations) around the client area.
    pub inline fn getBordersSize(self: *const Window) !BordersSize {
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

    /// Get the size of a window's client area, in pixels.
    pub inline fn getSizeInPixels(self: *const Window) !Size {
        var size: Size = undefined;
        try errify(c.SDL_GetWindowSizeInPixels(self.ptr, &size.width, &size.height));
        return size;
    }

    /// Set the minimum size of a window's client area.
    pub inline fn setMinimumSize(self: *const Window, min_size: Size) !void {
        try errify(c.SDL_SetWindowMinimumSize(self.ptr, min_size.width, min_size.height));
    }

    /// Get the minimum size of a window's client area.
    pub inline fn getMinimumSize(self: *const Window) !Size {
        var size: Size = undefined;
        try errify(c.SDL_GetWindowMinimumSize(self.ptr, &size.width, &size.height));
        return size;
    }

    /// Set the maximum size of a window's client area.
    pub inline fn setMaximumSize(self: *const Window, max_size: Size) !void {
        try errify(c.SDL_SetWindowMaximumSize(self.ptr, max_size.width, max_size.height));
    }

    /// Get the maximum size of a window's client area.
    pub inline fn getMaximumSize(self: *const Window) !Size {
        var size: Size = undefined;
        try errify(c.SDL_GetWindowMaximumSize(self.ptr, &size.width, &size.height));
        return size;
    }

    /// Set the border state of a window.
    pub inline fn setBordered(self: *const Window, bordered: bool) !void {
        try errify(c.SDL_SetWindowBordered(self.ptr, bordered));
    }

    /// Set the user-resizable state of a window.
    pub inline fn setResizable(self: *const Window, resizable: bool) !void {
        try errify(c.SDL_SetWindowResizable(self.ptr, resizable));
    }

    /// Set the window to always be above the others.
    pub inline fn setAlwaysOnTop(self: *const Window, on_top: bool) !void {
        try errify(c.SDL_SetWindowAlwaysOnTop(self.ptr, on_top));
    }

    /// Show a window.
    pub inline fn show(self: *const Window) !void {
        try errify(c.SDL_ShowWindow(self.ptr));
    }

    /// Hide a window.
    pub inline fn hide(self: *const Window) !void {
        try errify(c.SDL_HideWindow(self.ptr));
    }

    /// Request that a window be raised above other windows and gain the input focus.
    pub inline fn raise(self: *const Window) !void {
        try errify(c.SDL_RaiseWindow(self.ptr));
    }

    /// Request that the window be made as large as possible.
    pub inline fn maximize(self: *const Window) !void {
        try errify(c.SDL_MaximizeWindow(self.ptr));
    }

    /// Request that the window be minimized to an iconic representation.
    pub inline fn minimize(self: *const Window) !void {
        try errify(c.SDL_MinimizeWindow(self.ptr));
    }

    /// Request that the size and position of a minimized or maximized window be restored.
    pub inline fn restore(self: *const Window) !void {
        try errify(c.SDL_RestoreWindow(self.ptr));
    }

    /// Request that the window's fullscreen state be changed.
    pub inline fn setFullscreen(self: *const Window, fullscreen: bool) !void {
        try errify(c.SDL_SetWindowFullscreen(self.ptr, fullscreen));
    }

    /// Block until any pending window state is finalized.
    pub inline fn sync(self: *const Window) !void {
        try errify(c.SDL_SyncWindow(self.ptr));
    }

    /// Return whether the window has a surface associated with it.
    pub inline fn hasSurface(self: *const Window) bool {
        return c.SDL_WindowHasSurface(self.ptr);
    }

    /// Get the SDL surface associated with the window.
    pub inline fn getSurface(self: *const Window) !Surface {
        return .{
            .ptr = try errify(c.SDL_GetWindowSurface(self.ptr)),
        };
    }

    /// Toggle VSync for the window surface.
    pub inline fn setSurfaceVSync(self: *const Window, vsync: c_int) !void {
        try errify(c.SDL_SetWindowSurfaceVSync(self.ptr, vsync));
    }

    /// Get VSync for the window surface.
    pub inline fn getSurfaceVSync(self: *const Window) !c_int {
        var vsync: c_int = undefined;
        try errify(c.SDL_GetWindowSurfaceVSync(self.ptr, &vsync));
        return vsync;
    }

    /// Copy the window surface to the screen.
    pub inline fn updateSurface(self: *const Window) !void {
        try errify(c.SDL_UpdateWindowSurface(self.ptr));
    }

    /// Copy areas of the window surface to the screen.
    pub inline fn updateSurfaceRects(self: *const Window, rects: []const Rect) !void {
        try errify(c.SDL_UpdateWindowSurfaceRects(self.ptr, @ptrCast(rects.ptr), @intCast(rects.len)));
    }

    /// Destroy the surface associated with the window.
    pub inline fn destroySurface(self: *const Window) !void {
        try errify(c.SDL_DestroyWindowSurface(self.ptr));
    }

    /// Set a window's keyboard grab mode.
    pub inline fn setKeyboardGrab(self: *const Window, grabbed: bool) !void {
        try errify(c.SDL_SetWindowKeyboardGrab(self.ptr, grabbed));
    }

    /// Set a window's mouse grab mode.
    pub inline fn setMouseGrab(self: *const Window, grabbed: bool) !void {
        try errify(c.SDL_SetWindowMouseGrab(self.ptr, grabbed));
    }

    /// Get a window's keyboard grab mode.
    pub inline fn getKeyboardGrab(self: *const Window) bool {
        return c.SDL_GetWindowKeyboardGrab(self.ptr);
    }

    /// Get a window's mouse grab mode.
    pub inline fn getMouseGrab(self: *const Window) bool {
        return c.SDL_GetWindowMouseGrab(self.ptr);
    }

    /// Get the window that currently has an input grab enabled.
    pub inline fn getGrabbedWindow() ?Window {
        return if (c.SDL_GetGrabbedWindow()) |window| .{ .ptr = window } else null;
    }

    /// Confines the cursor to the specified area of a window.
    pub inline fn setMouseRect(self: *const Window, rectangle: ?Rect) !void {
        try errify(c.SDL_SetWindowMouseRect(self.ptr, @ptrCast(&rectangle)));
    }

    /// Get the mouse confinement rectangle of a window.
    pub inline fn getMouseRect(self: *const Window) ?Rect {
        return if (c.SDL_GetWindowMouseRect(self.ptr)) |rect_| @bitCast(rect_.*) else null;
    }

    /// Set the opacity for a window.
    pub inline fn setOpacity(self: *const Window, opacity: f32) !void {
        try errify(c.SDL_SetWindowOpacity(self.ptr, opacity));
    }

    /// Get the opacity of a window.
    pub inline fn getOpacity(self: *const Window) !f32 {
        return try errifyWithValue(
            c.SDL_GetWindowOpacity(self.ptr),
            -1,
        );
    }

    /// Set the window as a child of a parent window.
    pub inline fn setParent(self: *const Window, parent: Window) !void {
        try errify(c.SDL_SetWindowParent(self.ptr, parent.ptr));
    }

    /// Toggle the state of the window as modal.
    pub inline fn setModal(self: *const Window, modal: bool) !void {
        try errify(c.SDL_SetWindowModal(self.ptr, modal));
    }

    /// Set whether the window may have input focus.
    pub inline fn setFocusable(self: *const Window, focusable: bool) !void {
        try errify(c.SDL_SetWindowFocusable(self.ptr, focusable));
    }

    /// Display the system-level window menu.
    pub inline fn showSystemMenu(self: *const Window, point: Point) !void {
        try errify(c.SDL_ShowWindowSystemMenu(self.ptr, point.x, point.y));
    }

    /// Provide a callback that decides if a window region has special properties.
    pub inline fn setHitTest(self: *const Window, callback: ?c.SDL_HitTest, callback_data: ?*anyopaque) !void {
        try errify(c.SDL_SetWindowHitTest(self.ptr, callback, callback_data));
    }

    /// Set the shape of a transparent window.
    pub inline fn setShape(self: *const Window, shape: Surface) !void {
        try errify(c.SDL_SetWindowShape(self.ptr, shape.ptr));
    }

    /// Request a window to demand attention from the user.
    pub inline fn flashWindow(self: *const Window, operation: c.SDL_FlashOperation) !void {
        try errify(c.SDL_FlashWindow(self.ptr, operation));
    }
};

pub inline fn getWindows() ![]Window {
    var count: c_int = undefined;
    var window_ptrs = try errify(c.SDL_GetWindows(&count));
    return @ptrCast(window_ptrs[0..@intCast(count)]);
}

/// Check whether the screensaver is currently enabled.
pub inline fn screenSaverEnabled() bool {
    return c.SDL_ScreenSaverEnabled();
}

/// Allow the screen to be blanked by a screen saver.
pub inline fn enableScreenSaver() !void {
    try errify(c.SDL_EnableScreenSaver());
}

/// Prevent the screen from being blanked by a screen saver.
pub inline fn disableScreenSaver() !void {
    try errify(c.SDL_DisableScreenSaver());
}

pub const GLattr = enum(u32) {
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

        /// Create an OpenGL context for an OpenGL window, and make it current.
        pub inline fn create(window: Window) !GLContext {
            return .{
                .ctx = try errify(c.SDL_GL_CreateContext(window.ptr)),
            };
        }

        /// Set up an OpenGL context for rendering into an OpenGL window.
        pub inline fn makeCurrent(self: *const GLContext, window: Window) !void {
            try errify(c.SDL_GL_MakeCurrent(window.ptr, self.ctx));
        }

        /// Delete an OpenGL context.
        pub inline fn destroy(self: *const GLContext) !void {
            try errify(c.SDL_GL_DestroyContext(self.ctx));
        }
    };

    /// Dynamically load an OpenGL library.
    pub inline fn loadLibrary(path: [*:0]const u8) !void {
        try errify(c.SDL_GL_LoadLibrary(path));
    }

    /// Get an OpenGL function by name.
    pub inline fn getProcAddress(proc: [*:0]const u8) ?*const anyopaque {
        return c.SDL_GL_GetProcAddress(proc);
    }

    /// Unload the OpenGL library previously loaded by SDL_GL_LoadLibrary().
    pub inline fn unloadLibrary() void {
        c.SDL_GL_UnloadLibrary();
    }

    /// Check if an OpenGL extension is supported for the current context.
    pub inline fn extensionSupported(extension: [*:0]const u8) bool {
        return c.SDL_GL_ExtensionSupported(extension);
    }

    /// Reset all previously set OpenGL context attributes to their default values.
    pub inline fn resetAttributes() void {
        c.SDL_GL_ResetAttributes();
    }

    /// Set an OpenGL window attribute before window creation.
    pub inline fn setAttribute(attr: GLattr, value: c_int) !void {
        try errify(c.SDL_GL_SetAttribute(@intFromEnum(attr), value));
    }

    /// Get the actual value for an attribute from the current context.
    pub inline fn getAttribute(attr: GLattr) !c_int {
        var value: c_int = undefined;
        try errify(c.SDL_GL_GetAttribute(@intFromEnum(attr), &value));
        return value;
    }

    /// Get the currently active OpenGL window.
    pub inline fn getCurrentWindow() !Window {
        return .{
            .ptr = try errify(c.SDL_GL_GetCurrentWindow()),
        };
    }

    /// Get the currently active OpenGL context.
    pub inline fn getCurrentContext() GLContext {
        return c.SDL_GL_GetCurrentContext();
    }

    /// Set the swap interval for the current OpenGL context.
    pub inline fn setSwapInterval(interval: i32) !void {
        try errify(c.SDL_GL_SetSwapInterval(interval));
    }

    /// Get the swap interval for the current OpenGL context.
    pub inline fn getSwapInterval() !c_int {
        var interval: c_int = undefined;
        try errify(c.SDL_GL_GetSwapInterval(&interval));
        return interval;
    }

    /// Update a window with OpenGL rendering.
    pub inline fn swapWindow(window: Window) !void {
        try errify(c.SDL_GL_SwapWindow(window));
    }
};

pub const egl = struct {
    pub const EGLDisplay = c.SDL_EGLDisplay;
    pub const EGLConfig = c.SDL_EGLConfig;
    pub const EGLSurface = c.SDL_EGLSurface;
    pub const EGLAttribArrayCallback = c.SDL_EGLAttribArrayCallback;
    pub const EGLIntArrayCallback = c.SDL_EGLIntArrayCallback;

    /// Get an EGL library function by name.
    pub inline fn getProcAddress(proc: [*:0]const u8) ?c.SDL_FunctionPointer {
        return c.SDL_EGL_GetProcAddress(proc);
    }

    /// Get the currently active EGL display.
    pub inline fn getCurrentDisplay() !EGLDisplay {
        return try errify(c.SDL_EGL_GetCurrentDisplay());
    }

    /// Get the currently active EGL config.
    pub inline fn getCurrentConfig() !EGLConfig {
        return try errify(c.SDL_EGL_GetCurrentConfig());
    }

    /// Get the EGL surface associated with the window.
    pub inline fn getWindowSurface(window: Window) !EGLSurface {
        return try errify(c.SDL_EGL_GetWindowSurface(window.ptr));
    }

    /// Sets the callbacks for defining custom EGLAttrib arrays for EGL initialization.
    pub inline fn setAttributeCallbacks(
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

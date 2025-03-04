const std = @import("std");

const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;
pub const MouseID = c.SDL_MouseID;
const rect = @import("rect.zig");
const Rectangle = rect.Rectangle;
const video = @import("video.zig");
const Window = video.Window;

pub const SystemCursor = enum(u32) {
    default = c.SDL_SYSTEM_CURSOR_DEFAULT,
    text = c.SDL_SYSTEM_CURSOR_TEXT,
    wait = c.SDL_SYSTEM_CURSOR_WAIT,
    crosshair = c.SDL_SYSTEM_CURSOR_CROSSHAIR,
    progress = c.SDL_SYSTEM_CURSOR_PROGRESS,
    nwse_resize = c.SDL_SYSTEM_CURSOR_NWSE_RESIZE,
    nesw_resize = c.SDL_SYSTEM_CURSOR_NESW_RESIZE,
    ew_resize = c.SDL_SYSTEM_CURSOR_EW_RESIZE,
    ns_resize = c.SDL_SYSTEM_CURSOR_NS_RESIZE,
    move = c.SDL_SYSTEM_CURSOR_MOVE,
    not_allowed = c.SDL_SYSTEM_CURSOR_NOT_ALLOWED,
    pointer = c.SDL_SYSTEM_CURSOR_POINTER,
    nw_resize = c.SDL_SYSTEM_CURSOR_NW_RESIZE,
    n_resize = c.SDL_SYSTEM_CURSOR_N_RESIZE,
    ne_resize = c.SDL_SYSTEM_CURSOR_NE_RESIZE,
    e_resize = c.SDL_SYSTEM_CURSOR_E_RESIZE,
    se_resize = c.SDL_SYSTEM_CURSOR_SE_RESIZE,
    s_resize = c.SDL_SYSTEM_CURSOR_S_RESIZE,
    sw_resize = c.SDL_SYSTEM_CURSOR_SW_RESIZE,
    w_resize = c.SDL_SYSTEM_CURSOR_W_RESIZE,
};

pub const MouseWheelDirection = enum(u32) {
    normal = c.SDL_MOUSEWHEEL_NORMAL,
    flipped = c.SDL_MOUSEWHEEL_FLIPPED,
};

pub const MouseButtonFlags = struct {
    left: bool = false,
    middle: bool = false,
    right: bool = false,
    x1: bool = false,
    x2: bool = false,

    pub inline fn fromInt(flags: u32) MouseButtonFlags {
        return .{
            .left = flags & c.SDL_BUTTON_LMASK != 0,
            .middle = flags & c.SDL_BUTTON_MMASK != 0,
            .right = flags & c.SDL_BUTTON_RMASK != 0,
            .x1 = flags & c.SDL_BUTTON_X1MASK != 0,
            .x2 = flags & c.SDL_BUTTON_X2MASK != 0,
        };
    }
};

/// Return whether a mouse is currently connected.
pub inline fn hasMouse() bool {
    return c.SDL_HasMouse();
}

/// Get a list of currently connected mice.
pub inline fn getMice() ![]MouseID {
    var count: c_int = undefined;
    const mice = try errify(c.SDL_GetMice(&count));
    return @ptrCast(mice[0..@intCast(count)]);
}

/// Get the name of a mouse
pub inline fn getMouseNameForID(id: MouseID) ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetMouseNameForID(id)));
}

/// Get the window which currently has mouse focus.
pub inline fn getMouseFocus() ?Window {
    if (c.SDL_GetMouseFocus()) |ptr| {
        return Window{ .ptr = ptr };
    }
    return null;
}

/// Query SDL's cache for the synchronous mouse button state and position.
pub inline fn getMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return MouseButtonFlags.fromInt(c.SDL_GetMouseState(x, y));
}

/// Query the platform for the asynchronous mouse button state and position.
pub inline fn getGlobalMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return MouseButtonFlags.fromInt(c.SDL_GetGlobalMouseState(x, y));
}

/// Query SDL's cache for the synchronous mouse button state and accumulated delta.
pub inline fn getRelativeMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return MouseButtonFlags.fromInt(c.SDL_GetRelativeMouseState(x, y));
}

/// Move the mouse cursor to the given position within the window.
pub inline fn warpMouseInWindow(window: Window, x: f32, y: f32) void {
    c.SDL_WarpMouseInWindow(window.ptr, x, y);
}

/// Move the mouse to the given position in global screen space.
pub inline fn warpMouseGlobal(x: f32, y: f32) !void {
    try errify(c.SDL_WarpMouseGlobal(x, y));
}

/// Set relative mouse mode for a window.
pub inline fn setWindowRelativeMouseMode(window: Window, enabled: bool) !void {
    try errify(c.SDL_SetWindowRelativeMouseMode(window.ptr, enabled));
}

/// Query whether relative mouse mode is enabled for a window.
pub inline fn getWindowRelativeMouseMode(window: Window) bool {
    return c.SDL_GetWindowRelativeMouseMode(window.ptr);
}

/// Capture the mouse and to track input outside an SDL window.
pub inline fn captureMouse(enabled: bool) !void {
    try errify(c.SDL_CaptureMouse(enabled));
}

pub const Cursor = struct {
    ptr: *c.SDL_Cursor,

    /// Create a cursor using the specified bitmap data and mask.
    pub inline fn create(data: [*]const u8, mask: [*]const u8, w: i32, h: i32, hot_x: i32, hot_y: i32) !Cursor {
        return Cursor{ .ptr = try errify(c.SDL_CreateCursor(data, mask, w, h, hot_x, hot_y)) };
    }

    /// Create a color cursor.
    pub inline fn createColor(surface: *c.SDL_Surface, hot_x: i32, hot_y: i32) !Cursor {
        return Cursor{ .ptr = try errify(c.SDL_CreateColorCursor(surface, hot_x, hot_y)) };
    }

    /// Create a system cursor.
    pub inline fn createSystem(id: SystemCursor) !Cursor {
        return Cursor{ .ptr = try errify(c.SDL_CreateSystemCursor(@intFromEnum(id))) };
    }

    /// Free a previously-created cursor.
    pub inline fn destroy(self: Cursor) void {
        c.SDL_DestroyCursor(self.ptr);
    }

    /// Set the active cursor.
    pub inline fn set(self: Cursor) !void {
        try errify(c.SDL_SetCursor(self.ptr));
    }
};

/// Get the active cursor.
pub inline fn getCursor() ?Cursor {
    if (c.SDL_GetCursor()) |ptr| {
        return Cursor{ .ptr = ptr };
    }
    return null;
}

/// Get the default cursor.
pub inline fn getDefaultCursor() !Cursor {
    return Cursor{ .ptr = try errify(c.SDL_GetDefaultCursor()) };
}

/// Show the cursor.
pub inline fn showCursor() !void {
    try errify(c.SDL_ShowCursor());
}

/// Hide the cursor.
pub inline fn hideCursor() !void {
    try errify(c.SDL_HideCursor());
}

/// Return whether the cursor is currently being shown.
pub inline fn cursorVisible() bool {
    return c.SDL_CursorVisible();
}

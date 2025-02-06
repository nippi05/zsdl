const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const errify = internal.errify;
const video = @import("video.zig");
const Window = video.Window;
const rect = @import("rect.zig");
const Rectangle = rect.Rectangle;
const PropertiesID = video.PropertiesID;

pub const MouseID = c.SDL_MouseID;

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

    pub fn fromInt(flags: u32) MouseButtonFlags {
        return .{
            .left = flags & c.SDL_BUTTON_LMASK != 0,
            .middle = flags & c.SDL_BUTTON_MMASK != 0,
            .right = flags & c.SDL_BUTTON_RMASK != 0,
            .x1 = flags & c.SDL_BUTTON_X1MASK != 0,
            .x2 = flags & c.SDL_BUTTON_X2MASK != 0,
        };
    }
};

pub fn hasMouse() bool {
    return c.SDL_HasMouse();
}

pub fn getMice() ![]Mouse {
    var count: c_int = undefined;
    var mouse_ids = try errify(c.SDL_GetMice(&count));
    return @ptrCast(mouse_ids[0..@intCast(count)]);
}

pub fn getMouseFocus() ?Window {
    if (c.SDL_GetMouseFocus()) |ptr| {
        return .{
            .ptr = ptr,
        };
    }
    return null;
}

pub fn getMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return MouseButtonFlags.fromInt(c.SDL_GetMouseState(x, y));
}

pub fn getGlobalMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return MouseButtonFlags.fromInt(c.SDL_GetGlobalMouseState(x, y));
}

pub fn getRelativeMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return MouseButtonFlags.fromInt(c.SDL_GetRelativeMouseState(x, y));
}

pub fn warpMouseInWindow(window: ?Window, x: f32, y: f32) void {
    const win_ptr = if (window) |w| w.ptr else null;
    c.SDL_WarpMouseInWindow(win_ptr, x, y);
}

pub fn warpMouseGlobal(x: f32, y: f32) !void {
    try errify(c.SDL_WarpMouseGlobal(x, y));
}

pub fn setWindowRelativeMouseMode(window: Window, enabled: bool) !void {
    try errify(c.SDL_SetWindowRelativeMouseMode(window.ptr, enabled));
}

pub fn getWindowRelativeMouseMode(window: Window) bool {
    return c.SDL_GetWindowRelativeMouseMode(window.ptr);
}

pub fn captureMouse(enabled: bool) !void {
    try errify(c.SDL_CaptureMouse(enabled));
}

pub const Mouse = struct {
    id: MouseID,

    pub fn getName(self: Mouse) []const u8 {
        return std.mem.sliceTo(c.SDL_GetMouseNameForID(self.id), 0);
    }

    pub fn createCursor(_: Mouse, data: [*]const u8, mask: [*]const u8, w: i32, h: i32, hot_x: i32, hot_y: i32) !Cursor {
        return Cursor{ .ptr = try errify(c.SDL_CreateCursor(data, mask, w, h, hot_x, hot_y)) };
    }

    pub fn createColorCursor(_: Mouse, surface: *c.SDL_Surface, hot_x: i32, hot_y: i32) !Cursor {
        return Cursor{ .ptr = try errify(c.SDL_CreateColorCursor(surface, hot_x, hot_y)) };
    }

    pub fn createSystemCursor(_: Mouse, id: SystemCursor) !Cursor {
        return Cursor{ .ptr = try errify(c.SDL_CreateSystemCursor(@intFromEnum(id))) };
    }
};

pub const Cursor = struct {
    ptr: *c.SDL_Cursor,

    pub fn destroy(self: Cursor) void {
        c.SDL_DestroyCursor(self.ptr);
    }

    pub fn set(self: Cursor) !void {
        try errify(c.SDL_SetCursor(self.ptr));
    }
};

pub fn getCursor() ?Cursor {
    const ptr = c.SDL_GetCursor();
    return if (ptr != null) Cursor{ .ptr = ptr } else null;
}

pub fn getDefaultCursor() !Cursor {
    return Cursor{
        .ptr = try errify(c.SDL_GetDefaultCursor()),
    };
}

pub fn showCursor() !void {
    try errify(c.SDL_ShowCursor());
}

pub fn hideCursor() !void {
    try errify(c.SDL_HideCursor());
}

pub fn cursorVisible() bool {
    return c.SDL_CursorVisible();
}

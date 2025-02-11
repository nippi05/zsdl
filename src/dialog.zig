const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;
const Window = @import("video.zig").Window;

pub const DialogFileFilter = extern struct {
    name: [*c]const u8,
    pattern: [*c]const u8,
};

pub const DialogFileCallback = *const fn (
    userdata: ?*anyopaque,
    filelist: [*c]const [*c]const u8,
    filter: c_int,
) callconv(.C) void;

pub const FileDialogProperties = struct {
    filters: ?[]const DialogFileFilter = null,
    window: ?Window = null,
    location: ?[*:0]const u8 = null,
    allow_many: bool = false,
    title: ?[*:0]const u8 = null,
    accept: ?[*:0]const u8 = null,
    cancel: ?[*:0]const u8 = null,

    fn apply(self: FileDialogProperties, props: c.SDL_PropertiesID) void {
        if (self.filters) |f| {
            _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_FILE_DIALOG_FILTERS_POINTER, @ptrCast(@constCast(f.ptr)));
            _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_FILE_DIALOG_NFILTERS_NUMBER, @intCast(f.len));
        }
        if (self.window) |w| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_FILE_DIALOG_WINDOW_POINTER, @ptrCast(w.ptr));
        if (self.location) |l| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_FILE_DIALOG_LOCATION_STRING, l);
        _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_FILE_DIALOG_MANY_BOOLEAN, self.allow_many);
        if (self.title) |t| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_FILE_DIALOG_TITLE_STRING, t);
        if (self.accept) |a| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_FILE_DIALOG_ACCEPT_STRING, a);
        if (self.cancel) |ca| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_FILE_DIALOG_CANCEL_STRING, ca);
    }
};

pub const FileDialogType = enum(u32) {
    open_file = c.SDL_FILEDIALOG_OPENFILE,
    save_file = c.SDL_FILEDIALOG_SAVEFILE,
    open_folder = c.SDL_FILEDIALOG_OPENFOLDER,
};

/// Displays a dialog that lets the user select a file on their filesystem.
pub fn showOpenFileDialog(
    callback: DialogFileCallback,
    userdata: ?*anyopaque,
    window: ?Window,
    filters: ?[]const DialogFileFilter,
    default_location: ?[*:0]const u8,
    allow_many: bool,
) void {
    c.SDL_ShowOpenFileDialog(
        callback,
        userdata,
        if (window) |w| w.ptr else null,
        @ptrCast(filters),
        if (filters) |f| @intCast(f.len) else 0,
        default_location,
        allow_many,
    );
}

/// Displays a dialog that lets the user choose a new or existing file on their filesystem.
pub fn showSaveFileDialog(
    callback: DialogFileCallback,
    userdata: ?*anyopaque,
    window: ?Window,
    filters: ?[]const DialogFileFilter,
    default_location: ?[*:0]const u8,
) void {
    c.SDL_ShowSaveFileDialog(
        callback,
        userdata,
        if (window) |w| w.ptr else null,
        @ptrCast(filters),
        if (filters) |f| @intCast(f.len) else 0,
        default_location,
    );
}

/// Displays a dialog that lets the user select a folder on their filesystem.
pub fn showOpenFolderDialog(
    callback: DialogFileCallback,
    userdata: ?*anyopaque,
    window: ?Window,
    default_location: ?[*:0]const u8,
    allow_many: bool,
) void {
    c.SDL_ShowOpenFolderDialog(
        callback,
        userdata,
        if (window) |w| w.ptr else null,
        default_location,
        allow_many,
    );
}

/// Create and launch a file dialog with the specified properties.
pub fn showFileDialogWithProperties(
    dialog_type: FileDialogType,
    callback: DialogFileCallback,
    userdata: ?*anyopaque,
    prop: FileDialogProperties,
) void {
    const properties = c.SDL_CreateProperties();
    defer c.SDL_DestroyProperties(properties);
    prop.apply(properties);
    c.SDL_ShowFileDialogWithProperties(
        @intFromEnum(dialog_type),
        callback,
        userdata,
        properties,
    );
}

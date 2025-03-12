const std = @import("std");

pub const @"error" = @import("error.zig");
pub const audio = @import("audio.zig");
pub const blendmode = @import("blendmode.zig");
pub const c = @import("c.zig").c;
pub const MainThreadCallback = c.SDL_MainThreadCallback;
pub const camera = @import("camera.zig");
pub const clipboard = @import("clipboard.zig");
pub const dialog = @import("dialog.zig");
pub const events = @import("events.zig");
pub const gamepad = @import("gamepad.zig");
pub const gpu = @import("gpu.zig");
pub const Guid = @import("Guid.zig");
pub const haptic = @import("haptic.zig");
const internal = @import("internal.zig");
const errify = internal.errify;
pub const joystick = @import("joystick.zig");
pub const keyboard = @import("keyboard.zig");
pub const log = @import("log.zig");
pub const mouse = @import("mouse.zig");
pub const pixels = @import("pixels.zig");
pub const power = @import("power.zig");
pub const properties = @import("properties.zig");
pub const rect = @import("rect.zig");
pub const render = @import("render.zig");
pub const sensor = @import("sensor.zig");
pub const surface = @import("surface.zig");
pub const timer = @import("timer.zig");
pub const touch = @import("touch.zig");
pub const video = @import("video.zig");

pub const InitFlags = packed struct {
    pub const everything = InitFlags{
        .audio = true,
        .video = true,
        .joystick = true,
        .haptic = true,
        .gamepad = true,
        .events = true,
        .sensor = true,
        .camera = true,
    };

    audio: bool = false,
    video: bool = false,
    joystick: bool = false,
    haptic: bool = false,
    gamepad: bool = false,
    events: bool = false,
    sensor: bool = false,
    camera: bool = false,

    pub inline fn fromInt(flags: c.SDL_InitFlags) InitFlags {
        return .{
            .audio = (flags & c.SDL_INIT_AUDIO) != 0,
            .video = (flags & c.SDL_INIT_VIDEO) != 0,
            .joystick = (flags & c.SDL_INIT_JOYSTICK) != 0,
            .haptic = (flags & c.SDL_INIT_HAPTIC) != 0,
            .gamepad = (flags & c.SDL_INIT_GAMEPAD) != 0,
            .events = (flags & c.SDL_INIT_EVENTS) != 0,
            .sensor = (flags & c.SDL_INIT_SENSOR) != 0,
            .camera = (flags & c.SDL_INIT_CAMERA) != 0,
        };
    }

    pub inline fn toInt(self: InitFlags) c.SDL_InitFlags {
        return (if (self.audio) c.SDL_INIT_AUDIO else 0) |
            (if (self.video) c.SDL_INIT_VIDEO else 0) |
            (if (self.joystick) c.SDL_INIT_JOYSTICK else 0) |
            (if (self.haptic) c.SDL_INIT_HAPTIC else 0) |
            (if (self.gamepad) c.SDL_INIT_GAMEPAD else 0) |
            (if (self.events) c.SDL_INIT_EVENTS else 0) |
            (if (self.sensor) c.SDL_INIT_SENSOR else 0) |
            (if (self.camera) c.SDL_INIT_CAMERA else 0);
    }
};

/// Initialize the SDL library.
pub inline fn init(flags: InitFlags) !void {
    try errify(c.SDL_Init(flags.toInt()));
}

/// Compatibility function to initialize the SDL library.
pub inline fn initSubSystem(flags: InitFlags) !void {
    try errify(c.SDL_InitSubSystem(flags.toInt()));
}

/// Shut down specific SDL subsystems.
pub inline fn quitSubSystem(flags: InitFlags) void {
    c.SDL_QuitSubSystem(flags.toInt());
}

/// Get a mask of the specified subsystems which are currently initialized.
pub inline fn wasInit(flags: InitFlags) InitFlags {
    return InitFlags.fromInt(c.SDL_WasInit(flags.toInt()));
}

/// Clean up all initialized subsystems.
pub inline fn quit() void {
    c.SDL_Quit();
}

/// Return whether this is the main thread.
pub inline fn isMainThread() bool {
    return c.SDL_IsMainThread();
}

/// Call a function on the main thread during event processing.
pub inline fn runOnMainThread(callback: c.SDL_MainThreadCallback, userdata: ?*anyopaque, wait_complete: bool) !void {
    try errify(c.SDL_RunOnMainThread(callback, userdata, wait_complete));
}

/// Specify basic metadata about your app.
pub inline fn setAppMetadata(
    name: [:0]const u8,
    appversion: [:0]const u8,
    appidentifier: [:0]const u8,
) !void {
    try errify(c.SDL_SetAppMetadata(name, appversion, appidentifier));
}

pub const AppMetadataProperty = enum {
    name_string,
    version_string,
    identifier_string,
    creator_string,
    copyright_string,
    url_string,
    type_string,

    pub inline fn toString(property: AppMetadataProperty) [:0]const u8 {
        return switch (property) {
            .name_string => c.SDL_PROP_APP_METADATA_NAME_STRING,
            .version_string => c.SDL_PROP_APP_METADATA_VERSION_STRING,
            .identifier_string => c.SDL_PROP_APP_METADATA_IDENTIFIER_STRING,
            .creator_string => c.SDL_PROP_APP_METADATA_CREATOR_STRING,
            .copyright_string => c.SDL_PROP_APP_METADATA_COPYRIGHT_STRING,
            .url_string => c.SDL_PROP_APP_METADATA_URL_STRING,
            .type_string => c.SDL_PROP_APP_METADATA_TYPE_STRING,
        };
    }
};

/// Specify metadata about your app through a set of properties.
pub inline fn setAppMetadataProperty(
    property: AppMetadataProperty,
    value: [:0]const u8,
) !void {
    try errify(c.SDL_SetAppMetadataProperty(property.toString(), value));
}

/// Get metadata about your app.
pub inline fn getAppMetadataProperty(
    property: AppMetadataProperty,
) []const u8 {
    return std.mem.span(c.SDL_GetAppMetadataProperty(property.toString()));
}

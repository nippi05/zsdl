const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const errify = internal.errify;

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

    pub fn fromInt(flags: c.SDL_InitFlags) InitFlags {
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

    pub fn toInt(self: InitFlags) c.SDL_InitFlags {
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

pub fn init(flags: InitFlags) !void {
    try errify(c.SDL_Init(flags.toInt()));
}

pub fn initSubSystem(flags: InitFlags) !void {
    try errify(c.SDL_InitSubSystem(flags.toInt()));
}

pub fn quitSubSystem(flags: InitFlags) void {
    c.SDL_QuitSubSystem(flags.toInt());
}

pub fn wasInit(flags: InitFlags) InitFlags {
    return InitFlags.fromInt(c.SDL_WasInit(flags.toInt()));
}

pub fn quit() void {
    c.SDL_Quit();
}

pub fn isMainThread() bool {
    return c.SDL_IsMainThread();
}

pub const MainThreadCallback = c.SDL_MainThreadCallback;

pub fn runOnMainThread() !void { // FIXME
    try errify(c.SDL_MainThreadCallback());
}

pub fn setAppMetadata(
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

    pub fn toString(property: AppMetadataProperty) [:0]const u8 {
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

pub fn setAppMetadataProperty(
    property: AppMetadataProperty,
    value: [:0]const u8,
) !void {
    try errify(c.SDL_SetAppMetadataProperty(property.toString(), value));
}

pub fn getAppMetadataProperty(
    property: AppMetadataProperty,
) []const u8 {
    return std.mem.sliceTo(
        c.SDL_GetAppMetadataProperty(property.toString()),
        0,
    );
}

pub const video = @import("video.zig");
pub const rect = @import("rect.zig");
pub const keyboard = @import("keyboard.zig");
pub const mouse = @import("mouse.zig");
pub const touch = @import("touch.zig");
pub const Error = @import("Error.zig");

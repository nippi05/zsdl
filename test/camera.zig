const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const camera = zsdl.camera;
const print = std.debug.print;

test "camera" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.Error.get()});

    try zsdl.init(.{ .video = true, .camera = true });
    defer zsdl.quit();
    }
}

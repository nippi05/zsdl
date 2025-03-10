const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const camera = zsdl.camera;
const print = std.debug.print;

test "camera" {
    errdefer |err| if (err == error.SdlError) std.log.err("sdl err: {s}", .{zsdl.@"error".getError()});

    try zsdl.init(.{ .video = true, .camera = true });
    defer zsdl.quit();

    const cams = try camera.getCameras();
    std.debug.print("{any}\n", .{cams});
    const cam = try camera.Camera.open(cams[0], null);
    defer cam.close();
    std.debug.print("{s}\n", .{try cam.getName()});
    _ = try cam.getSupportedFormats();
}

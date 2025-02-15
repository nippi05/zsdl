const zsdl = @import("zsdl");

test "graphics pipeline" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try zsdl.video.Window.create("lol", 300, 300, .{ .resizable = true });
    defer window.destroy();

    const device = try zsdl.gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();
}

const zsdl = @import("zsdl");
const events = zsdl.events;

test "window" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try zsdl.video.Window.create(
        "lol",
        400,
        400,
        .{ .resizable = true },
    );
    window.destroy();
}

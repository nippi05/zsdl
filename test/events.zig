const std = @import("std");
const print = std.debug.print;

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
    defer window.destroy();

    main_loop: while (true) {
        while (events.pollEvent()) |event| {
            switch (event) {
                .quit => {
                    break :main_loop;
                },
                .window => |w| {
                    switch (w.data) {
                        .shown => {},
                        .resized => |size| {
                            print(
                                "window resized: (w: {any}, h: {any})\n",
                                .{ size.width, size.height },
                            );
                        },
                        else => {},
                    }
                },
                .keyboard => |k| {
                    switch (k.data) {
                        .down => |key| {
                            _ = key;
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }
    }
}

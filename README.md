# zsdl - SDL3 wrapper for Zig
SDL3 wrapper for Zig 0.14.0 built on top of [castholm/SDL](https://github.com/castholm/SDL)'s Zig build system implementation for SDL.

Check out the [documentation](https://mdmrk.github.io/zsdl/) for more info.

## Usage
```sh
zig fetch --save git+https://github.com/mdmrk/zsdl.git
```
```zig
const zsdl = b.dependency("zsdl", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zsdl", zsdl.module("zsdl"));
```

## Example
```zig
const std = @import("std");

const zsdl = @import("zsdl");

pub fn main() !void {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try zsdl.video.Window.create(
        "redbed",
        1280,
        720,
        .{ .resizable = true },
    );
    defer window.destroy();

    main_loop: while (true) {
        while (zsdl.events.pollEvent()) |event| {
            switch (event) {
                .quit => {
                    break :main_loop;
                },
                .window => |w| {
                    switch (w.data) {
                        .resized => |size| {
                            std.debug.print(
                                "window resized: (w: {any}, h: {any})\n",
                                .{ size.width, size.height },
                            );
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }
    }
}

```

## Support
| Category | Status |
|:-|:-:|
| Init | 🧪 |
| Hints | ❌ |
| Error | 🧪 |
| Properties | ❌ |
| Log | ✅ |
| Video | 🧪 |
| Events | 🧪 |
| Keyboard | 🧪 |
| Mouse | 🧪 |
| Touch | ✅ |
| Gamepad | 🧪 |
| Joystick | 🧪 |
| Haptic | 🧪 |
| Audio | ❌ |
| Gpu | 🧪 |
| Clipboard | ✅ |
| Dialog | ✅ |
| Filesystem | ❌ |
| Iostream | ❌ |
| Atomic | ❌ |
| Time | ❌ |
| Timer | 🧪 |
| Render | 🧪 |
| Pixels | ✅ |
| Surface | 🧪 |
| Platform | ❌ |
| Misc | ❌ |
| Main | ❌ |
| Strings | ❌ |
| CPU | ❌ |
| Intrinsics | ❌ |
| Locale | ❌ |
| System | ❌ |
| Metal | ❌ |
| Vulkan | ❌ |

Legend:
- ✅ Fully implemented
- 🧪 Partially implemented/experimental
- ❌ Not implemented

## Supported targets
Refer to [supported targets](https://github.com/castholm/SDL?tab=readme-ov-file#supported-targets).

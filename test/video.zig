const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const egl = zsdl.video.egl;
const c = zsdl.c;
const Window = zsdl.video.Window;

// test "egl.getProcAddress" {
//     try zsdl.init(.{ .video = true });
//     defer zsdl.quit();

//     const proc_name = "eglCreateContext\x00";
//     const proc = egl.getProcAddress(proc_name);
//     _ = proc;
// }

// test "egl.getCurrentDisplay" {
//     try zsdl.init(.{ .video = true });
//     defer zsdl.quit();

//     try testing.expectError(error.SDLError, egl.getCurrentDisplay());
// }

// test "egl.getCurrentConfig" {
//     try zsdl.init(.{ .video = true });
//     defer zsdl.quit();

//     try testing.expectError(error.SDLError, egl.getCurrentConfig());
// }

// test "egl.getWindowSurface" {
//     try zsdl.init(.{ .video = true });
//     defer zsdl.quit();

//     const window = try zsdl.video.Window.create(
//         "Test Window",
//         100,
//         100,
//         .{ .opengl = true },
//     );
//     defer window.destroy();

//     try testing.expectError(error.SDLError, egl.getWindowSurface(window));
// }

// test "egl.setAttributeCallbacks" {
//     try zsdl.init(.{ .video = true });
//     defer zsdl.quit();

//     // Test with null callbacks
//     egl.setAttributeCallbacks(null, null, null, null);

//     const platform_attrib = [_]c.SDL_EGLAttrib{0};
//     const surface_attrib = [_]c.SDL_EGLint{0};

//     const platformAttribCallback: c.SDL_EGLAttribArrayCallback = struct {
//         fn callback(_: ?*anyopaque) callconv(.C) [*c]c.SDL_EGLAttrib {
//             return @constCast(&platform_attrib);
//         }
//     }.callback;

//     const surfaceAttribCallback: c.SDL_EGLIntArrayCallback = struct {
//         fn callback(_: ?*anyopaque, _: c.SDL_EGLDisplay, _: c.SDL_EGLConfig) callconv(.C) [*c]c.SDL_EGLint {
//             return @constCast(&surface_attrib);
//         }
//     }.callback;

//     egl.setAttributeCallbacks(
//         platformAttribCallback,
//         surfaceAttribCallback,
//         surfaceAttribCallback,
//         null,
//     );
// }

// test "egl all functions availability" {
//     try testing.expect(@TypeOf(egl.getProcAddress) == fn ([*:0]const u8) ?c.SDL_FunctionPointer);
//     try testing.expect(@TypeOf(egl.getCurrentDisplay) == fn () error{SDLError}!egl.EGLDisplay);
//     try testing.expect(@TypeOf(egl.getCurrentConfig) == fn () error{SDLError}!egl.EGLConfig);
//     try testing.expect(@TypeOf(egl.getWindowSurface) == fn (Window) error{SDLError}!egl.EGLSurface);
//     try testing.expect(@TypeOf(egl.setAttributeCallbacks) == fn (
//         ?egl.EGLAttribArrayCallback,
//         ?egl.EGLIntArrayCallback,
//         ?egl.EGLIntArrayCallback,
//         ?*anyopaque,
//     ) void);
// }

test "create window with properties" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try Window.createWithProperties(.{ .resizable = true });
    defer window.destroy();
}

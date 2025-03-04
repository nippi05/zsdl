const std = @import("std");

const zsdl = @import("zsdl");
const log = zsdl.log;
const gpu = zsdl.gpu;

test "log" {
    log.setLogPriorities(.verbose);

    try zsdl.setAppMetadata("LLOL", "1.0.0", "Com.");
    try zsdl.init(.everything);
    defer zsdl.quit();

    const dev = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer dev.destroy();

    std.debug.print("{}\n", .{log.getLogPriority(.application)});
}

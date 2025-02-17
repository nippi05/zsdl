const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zsdl_mod = b.addModule("zsdl", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const zsdl = b.addLibrary(.{
        .root_module = zsdl_mod,
        .linkage = .static,
        .name = "zsdl",
    });

    const sdl = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl.artifact("SDL3");
    zsdl.linkLibrary(sdl_lib);

    const docs = b.addInstallDirectory(.{
        .source_dir = zsdl.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Generate library documentation");
    docs_step.dependOn(&docs.step);

    var tests_dir = try std.fs.cwd().openDir("test", .{ .iterate = true });
    var iter = tests_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        const test_file = b.addTest(.{
            .root_source_file = b.path(b.pathJoin(&.{ "test", entry.name })),
            .target = target,
        });
        const basename = std.fs.path.basename(entry.name);
        const test_name = basename[0 .. basename.len - ".zig".len];
        test_file.root_module.addImport("zsdl", zsdl_mod);
        const run_tests = b.addRunArtifact(test_file);
        const test_step = b.step(b.fmt("test-{s}", .{test_name}), b.fmt("Run test/{s} tests", .{entry.name}));
        test_step.dependOn(&zsdl.step);
        test_step.dependOn(&run_tests.step);
    }
}

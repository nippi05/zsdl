const std = @import("std");

pub fn addTests(
    b: *std.Build,
    zsdl_mod: *std.Build.Module,
    zsdl_step: *std.Build.Step,
    target: std.Build.ResolvedTarget,
) !void {
    var tests_dir = try b.build_root.handle.openDir("test", .{ .iterate = true });
    var iter = tests_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;

        const basename = std.fs.path.basename(entry.name);
        const test_name = basename[0 .. basename.len - ".zig".len];

        const test_exe = b.addTest(.{
            .name = test_name,
            .root_source_file = b.path(b.pathJoin(&.{ "test", entry.name })),
            .target = target,
            .optimize = .Debug,
        });

        test_exe.root_module.addImport("zsdl", zsdl_mod);
        const install_test = b.addInstallArtifact(test_exe, .{});
        const test_step = b.step(b.fmt("test-{s}", .{test_name}), b.fmt("Build test/{s} executable", .{entry.name}));

        test_step.dependOn(zsdl_step);
        test_step.dependOn(&install_test.step);
    }
}

pub fn build(b: *std.Build) void {
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

    addTests(b, zsdl_mod, &zsdl.step, target) catch {};
}

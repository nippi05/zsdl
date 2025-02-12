const std = @import("std");

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
}

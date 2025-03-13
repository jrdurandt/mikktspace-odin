const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "mikktspace",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();
    lib.addIncludePath(b.path("src/mikktspace.h"));
    lib.addCSourceFiles(.{
        .files = &.{
            "src/mikktspace.c",
        },
        .flags = &.{
            "-fPIC",
        },
    });

    const dst = switch (target.result.os.tag) {
        .windows => "../lib/windows",
        .linux => "../lib/linux",
        .macos => "../lib/macos",
        else => unreachable,
    };

    const install_artifact = b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .{ .custom = dst } },
    });
    b.getInstallStep().dependOn(&install_artifact.step);
}

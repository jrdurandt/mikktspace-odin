const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSafe,
    });

    const mikktspace = b.dependency("mikktspace_zig", .{
        .target = target,
        .optimize = optimize,
    });

    //Copies library to root directory
    b.getInstallStep().dependOn(&b.addInstallArtifact(mikktspace.artifact("mikktspace"), .{
        .dest_dir = .{ .override = .{ .custom = "../" } },
    }).step);
}

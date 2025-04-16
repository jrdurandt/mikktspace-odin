const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const mikktspace = b.dependency("mikktspace_zig", .{
        .target = target,
        .optimize = .ReleaseFast,
    });

    //Copies library to root directory
    b.getInstallStep().dependOn(&b.addInstallArtifact(mikktspace.artifact("mikktspace"), .{
        .dest_dir = .{ .override = .{ .custom = "../" } },
    }).step);
}

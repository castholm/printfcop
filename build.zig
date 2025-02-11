// © 2025 Carl Åstholm
// SPDX-License-Identifier: MIT

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("printfcop", .{
        .root_source_file = b.path("printfcop.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = mod;

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("printfcop.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}

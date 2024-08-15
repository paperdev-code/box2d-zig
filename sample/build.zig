const std = @import("std");
const zigglgen = @import("zigglgen");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sample",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const box2d = b.dependency("box2d", .{}).module("box2d");
    const glfw = b.dependency("glfw", .{}).artifact("glfw");
    const gl = zigglgen.generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.6",
        .profile = .core,
    });

    exe.root_module.addImport("box2d", box2d);
    exe.root_module.addImport("gl", gl);
    exe.linkLibrary(glfw);

    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "run sample app.");
    run_step.dependOn(&run.step);
}

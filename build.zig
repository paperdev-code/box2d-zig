const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libbox2d = b.addStaticLibrary(.{
        .name = "box2d",
        .optimize = optimize,
        .target = target,
    });

    const box2d_source = b.dependency("box2d_source", .{});

    libbox2d.addCSourceFiles(.{
        .root = box2d_source.path("src"),
        .files = &[_][]const u8{
            "aabb.c",
            "allocate.c",
            "array.c",
            "bitset.c",
            "block_array.c",
            "body.c",
            "broad_phase.c",
            "constraint_graph.c",
            "contact.c",
            "contact_solver.c",
            "core.c",
            "distance.c",
            "distance_joint.c",
            "dynamic_tree.c",
            "geometry.c",
            "hull.c",
            "id_pool.c",
            "island.c",
            "joint.c",
            "manifold.c",
            "math_functions.c",
            "motor_joint.c",
            "mouse_joint.c",
            "prismatic_joint.c",
            "revolute_joint.c",
            "shape.c",
            "solver.c",
            "solver_set.c",
            "stack_allocator.c",
            "table.c",
            "timer.c",
            "types.c",
            "weld_joint.c",
            "wheel_joint.c",
            "world.c",
        },
        .flags = &[_][]const u8{},
    });

    // TODO: we can get rid of libc by adding some
    //       zig based replacements for certain source files.
    //       (like the vec2, timers and allocation)
    libbox2d.linkLibC();
    libbox2d.addIncludePath(box2d_source.path("extern/simde"));
    libbox2d.addIncludePath(box2d_source.path("include"));

    if (optimize == .ReleaseSafe) {
        libbox2d.defineCMacro("B2_ENABLE_ASSERT", null);
    }

    const box2d = b.addModule("box2d", .{
        .root_source_file = b.path("src/box2d.zig"),
        .optimize = optimize,
        .target = target,
    });

    box2d.linkLibrary(libbox2d);
    box2d.addIncludePath(box2d_source.path("include"));

    b.installArtifact(libbox2d);
}

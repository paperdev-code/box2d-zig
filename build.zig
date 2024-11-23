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

    libbox2d.linkLibC();
    libbox2d.addIncludePath(box2d_source.path("extern/simde"));
    libbox2d.addIncludePath(box2d_source.path("include"));

    if (optimize == .ReleaseSafe) {
        libbox2d.defineCMacro("B2_ENABLE_ASSERT", null);
    }

    const box2d_c = b.addTranslateC(.{
        .root_source_file = box2d_source.path("include/box2d/box2d.h"),
        .optimize = optimize,
        .target = target,
    });

    const box2d = b.addModule("box2d", .{
        .root_source_file = b.path("src/box2d.zig"),
        .optimize = optimize,
        .target = target,
    });

    box2d.addImport("box2d.h", box2d_c.createModule());
    box2d.linkLibrary(libbox2d);
    box2d.addIncludePath(box2d_source.path("include"));

    b.installArtifact(libbox2d);

    const module_test = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
    });

    module_test.root_module.addImport("box2d", box2d);

    const tests = b.step("test", "run box2d unit tests, requires '-Dbox2d_tests' option.");
    const expose_tests = b.option(bool, "box2d_tests", "exposes 'zig build test' for box2d tests.");

    const run_module_test = b.addRunArtifact(module_test);
    tests.dependOn(&run_module_test.step);

    if (expose_tests orelse false) {
        const test_runner = b.addExecutable(.{
            .name = "box2d_tests",
            .target = target,
            .optimize = .Debug,
        });

        test_runner.addCSourceFiles(.{
            .root = box2d_source.path("test"),
            .files = &[_][]const u8{
                "main.c",
                "test_bitset.c",
                "test_collision.c",
                "test_determinism.c",
                "test_distance.c",
                "test_math.c",
                "test_shape.c",
                "test_table.c",
                "test_world.c",
            },
            .flags = &[_][]const u8{},
        });

        const enkits = b.lazyDependency("enkits", .{}) orelse return;
        const libenkits = b.addStaticLibrary(.{
            .name = "enkiTS",
            .target = target,
            .optimize = .ReleaseFast,
        });

        libenkits.addCSourceFiles(.{
            .root = enkits.path("src"),
            .files = &[_][]const u8{
                "TaskScheduler.cpp",
                "TaskScheduler_c.cpp",
            },
        });

        libenkits.linkLibCpp();
        libenkits.addIncludePath(enkits.path("src"));

        test_runner.linkLibrary(libbox2d);
        test_runner.linkLibrary(libenkits);
        test_runner.addIncludePath(box2d_source.path("include"));
        test_runner.addIncludePath(box2d_source.path("src"));
        test_runner.addIncludePath(enkits.path("src"));

        const run_box2d_tests = b.addRunArtifact(test_runner);
        tests.dependOn(&run_box2d_tests.step);
    }
}

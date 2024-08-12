const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const box2d = getImport(b, .{
        .target = target,
        .optimize = optimize,
        .linkage = .static,
    });

    const @"test" = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
    });

    @"test".root_module.addImport("box2d", box2d.module);
    b.step("test", "run integration test").dependOn(&@"test".step);

    b.installArtifact(box2d.library);
}

pub const Box2dOptions = struct {
    pub const Linkage = enum { dynamic, static };

    linkage: Linkage,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

pub const Box2dImport = struct {
    module: *std.Build.Module,
    library: *std.Build.Step.Compile,
    include_path: std.Build.LazyPath,
};

pub fn getImport(b: *std.Build, options: Box2dOptions) Box2dImport {
    const box2d_source = b.dependency("box2d_source", .{});
    const box2d_include = box2d_source.path("include");

    const libbox2d = buildLibrary(b, box2d_source, options);

    const box2d = b.addModule("box2d", .{
        .root_source_file = b.path("src/box2d.zig"),
    });
    box2d.linkLibrary(libbox2d);
    box2d.addIncludePath(box2d_include);

    return .{
        .module = box2d,
        .library = libbox2d,
        .include_path = box2d_include,
    };
}

fn buildLibrary(b: *std.Build, source: *std.Build.Dependency, options: Box2dOptions) *std.Build.Step.Compile {
    const library_options = .{
        .name = "box2d",
        .target = options.target,
        .optimize = options.optimize,
    };

    const libbox2d = switch (options.linkage) {
        .dynamic => b.addSharedLibrary(library_options),
        .static => b.addStaticLibrary(library_options),
    };

    libbox2d.linkLibC();

    libbox2d.addCSourceFiles(.{
        .root = source.path("src"),
        .files = &[_][]const u8{
            "distance_joint.c",
            "types.c",
            "stack_allocator.c",
            "joint.c",
            "timer.c",
            "wheel_joint.c",
            "distance.c",
            "contact.c",
            "id_pool.c",
            "weld_joint.c",
            "broad_phase.c",
            "manifold.c",
            "contact_solver.c",
            "mouse_joint.c",
            "array.c",
            "hull.c",
            "table.c",
            "solver_set.c",
            "shape.c",
            "aabb.c",
            "core.c",
            "body.c",
            "solver.c",
            "constraint_graph.c",
            "motor_joint.c",
            "world.c",
            "island.c",
            "block_array.c",
            "math_functions.c",
            "prismatic_joint.c",
            "allocate.c",
            "revolute_joint.c",
            "geometry.c",
            "dynamic_tree.c",
            "bitset.c",
        },
        .flags = &[_][]const u8{},
    });

    // SIMD extension lib
    libbox2d.addIncludePath(source.path("extern/simde"));
    libbox2d.addIncludePath(source.path("include"));

    if (options.linkage == .dynamic) {
        libbox2d.defineCMacro("BOX2D_DLL", null);
    }

    if (options.optimize == .ReleaseSafe) {
        libbox2d.defineCMacro("B2_ENABLE_ASSERT", null);
    }

    return libbox2d;
}

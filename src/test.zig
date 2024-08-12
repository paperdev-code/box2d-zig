const std = @import("std");

test "import" {
    const box2d = @import("box2d");

    const world: box2d.c.b2WorldId = .{};

    try std.testing.expectEqual(
        world.revision,
        std.mem.zeroes(@TypeOf(world.revision)),
    );
}

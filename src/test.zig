//! test file for box2d's zig module
//! this does not test the box2d library, only the bindings.
const box2d = @import("box2d");

// small Zig rewrite of an existing box2d test, see github#erincatto/box2d/test_collision.c
// used to test and show the C bindings.
test "collision" {
    const testing = @import("std").testing;
    const c = box2d.c;

    var a = c.b2AABB{};

    a.lowerBound = .{ .x = -1.0, .y = -1.0 };
    a.upperBound = .{ .x = -2.0, .y = -2.0 };

    try testing.expect(c.b2AABB_IsValid(a) == false);

    a.upperBound = .{ .x = 1.0, .y = 1.0 };

    try testing.expect(c.b2AABB_IsValid(a) == true);

    const b = c.b2AABB{
        .lowerBound = .{ .x = 2.0, .y = 2.0 },
        .upperBound = .{ .x = 4.0, .y = 4.0 },
    };

    try testing.expect(c.b2AABB_Contains(a, b) == false);
}

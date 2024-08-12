/// C API directly from Box2D.
pub const c = @cImport({
    @cInclude("box2d/box2d.h");
});

test {
    const world: c.b2WorldId = undefined;
    _ = world;
}

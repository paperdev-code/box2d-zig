/// C API directly from Box2D.
/// TODO: replace with TranslateCStep when it accepts lazypaths.
/// https://github.com/ziglang/zig/issues/20630
pub const c = @cImport({
    @cInclude("box2d/box2d.h");
});

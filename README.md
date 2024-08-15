# Zig build support for Box2D 3.0.0
WIP. Currently only exposes a `box2d.c` struct for including and using box2d. I still got to try making something with it.

## Usage
Running `zig build` compiles `box2d` to a static library. It is also available as a zig module. Check the `sample/build.zig` and `main.zig` for example usage.

## Test
Box2D requires an additional dependency to run tests. This is lazily loaded and it's tests aren't exposed through `zig build test` unless `-Dbox2d_tests` is specified.

## Roadmap
 - [x] expose the C api.
 - [x] run the box2d unit tests.
 - [ ] create an example application, preferably with zig's package manager.
 - [ ] try to get rid of libc?
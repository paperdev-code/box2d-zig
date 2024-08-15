const std = @import("std");
const box2d = @import("box2d");
const gl = @import("gl");

const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", {});
    @cInclude("GLFW/glfw3.h");
});

pub fn main() !void {
    var window: ?*c.GLFWwindow = undefined;

    if (c.glfwInit() == 0) {
        return error.GLFWInitFail;
    }
    defer c.glfwTerminate();

    window = c.glfwCreateWindow(640, 480, "Hello, world!", null, null);

    if (window) |_| {} else {
        c.glfwTerminate();
        return error.GlfwCreateWindowFail;
    }

    c.glfwMakeContextCurrent(window);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwPollEvents();
    }
}

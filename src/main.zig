const std = @import("std");
const game = @import("game.zig");
const input = @import("input.zig");

extern fn consoleLog(arg: u32) void;

extern fn gameResult(arg: bool) void;

var state = game.State.new();

// The returned pointer will be used as an offset integer to the wasm memory
// BE CAREFUL! reassigning state to a new struct in zig then accessing the old pointer
// from js can/will result in a memory access error
export fn getCanvasBufferPointer() [*]u8 {
    return @ptrCast(&state.canvas_buffer);
}

export fn getCanvasSize() usize {
    return game.CANVAS_SIZE;
}

export fn seedRng(seed: u64) void {
    state.seed(seed);
    state.randomize();
}
export fn drawCanvas() void {
    state.draw();
}

export fn onInput(key: input.Key) void {
    const dire = input.toDirection(key);
    if (state.move(dire)) |result| {
        gameResult(result);
        state.randomize();
    }
}

const std = @import("std");
const game = @import("game.zig");
const basictiles = @import("basictiles.zig");
const object = @import("object.zig");

const CANVAS_SIZE = game.CANVAS_SIZE;
const MAP_DIMS = game.MAP_DIMS;

pub fn empty() game.State {
    return game.State{
        .prng = std.Random.DefaultPrng.init(0),
        .canvas_buffer = std.mem.zeroes(
            [CANVAS_SIZE][CANVAS_SIZE][4]u8,
        ),
        .background_buffer = std.mem.zeroes(
            [MAP_DIMS.w][MAP_DIMS.h]basictiles.BasicTile,
        ),
        .foreground_buffer = std.mem.zeroes(
            [MAP_DIMS.w][MAP_DIMS.h]?object.Object,
        ),
    };
}

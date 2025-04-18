const std = @import("std");
const game = @import("game.zig");
const position = @import("position.zig");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");

const CANVAS_SIZE = game.CANVAS_SIZE;
const MAP_DIMS = game.MAP_DIMS;

pub fn randomFillTileBuffer(state: *game.State) void {
    const rand = state.prng.random();
    for (0..MAP_DIMS.w) |x| {
        for (0..MAP_DIMS.h) |y| {
            const grass = rand.int(u8) % 4;
            if (grass == 0) {
                state.background_buffer[x][y] = .grass1;
            } else if (grass == 1) {
                state.background_buffer[x][y] = .grass2;
            } else if (grass == 2) {
                state.background_buffer[x][y] = .grass3;
            } else {
                state.background_buffer[x][y] = .grass4;
            }
        }
    }
}

pub fn randomFillObjectBuffer(state: *game.State) void {
    const rand = state.prng.random();
    state.foreground_buffer = std.mem.zeroes(
        [MAP_DIMS.w][MAP_DIMS.h]?basictiles.BasicTile,
    );
    for (0..10) |_| {
        const cx = rand.int(u8) % MAP_DIMS.w;
        const cy = rand.int(u8) % MAP_DIMS.h;
        const i = rand.int(u8) % 2;
        if (i == 0) {
            state.foreground_buffer[cx][cy] = .shrub1;
        } else {
            state.foreground_buffer[cx][cy] = .pot;
        }
    }
}

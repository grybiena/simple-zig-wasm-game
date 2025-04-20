const std = @import("std");
const game = @import("game.zig");
const position = @import("position.zig");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const object = @import("object.zig");

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
    state.foreground_buffer = std.mem.zeroes(
        [MAP_DIMS.w][MAP_DIMS.h]?object.Object,
    );
    placePushables(state);
    placeStatics(state);
    placeGoals(state);
    placeCharacter(state, .tom);
    placeCharacter(state, .ada);
}

pub fn placePushables(state: *game.State) void {
    // we don't place at the edges for now
    // NOTE we can still end up generating unsolvable games this way
    // e.g. surrounding an object with statics
    // TODO solve the constraint problem - is this game solvable?
    const rand = state.prng.random();
    for (0..5) |_| {
        const cx = 1 + rand.int(u8) % (MAP_DIMS.w - 2);
        const cy = 1 + rand.int(u8) % (MAP_DIMS.h - 2);
        state.foreground_buffer[cx][cy] = object.Object{ .pushable = .pot };
    }
}

pub fn placeStatics(state: *game.State) void {
    const rand = state.prng.random();
    var statics_placed: u8 = 0;
    while (statics_placed < 5) {
        const cx = rand.int(u8) % MAP_DIMS.w;
        const cy = rand.int(u8) % MAP_DIMS.h;
        if (state.foreground_buffer[cx][cy] != null) continue;
        state.foreground_buffer[cx][cy] = object.Object{ .static = .shrub };
        statics_placed += 1;
    }
}

pub fn placeGoals(state: *game.State) void {
    const rand = state.prng.random();
    var goals_placed: u8 = 0;
    while (goals_placed < 5) {
        const cx = rand.int(u8) % MAP_DIMS.w;
        const cy = rand.int(u8) % MAP_DIMS.h;
        if (state.foreground_buffer[cx][cy] != null) continue;
        state.foreground_buffer[cx][cy] = object.Object{ .goal = .empty };
        goals_placed += 1;
    }
}

pub fn placeCharacter(state: *game.State, who: characters.Identity) void {
    const rand = state.prng.random();
    var placed = false;
    while (!placed) {
        const cx = rand.int(u8) % MAP_DIMS.w;
        const cy = rand.int(u8) % MAP_DIMS.h;
        if (state.foreground_buffer[cx][cy] != null) continue;
        state.foreground_buffer[cx][cy] = object.Object{ .character = object.Character{ .sprite = who, .direction = .down } };
        placed = true;
    }
}

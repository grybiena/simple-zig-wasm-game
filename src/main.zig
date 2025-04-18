const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const game = @import("game.zig");
const coord = @import("coord.zig");
const direction = @import("direction.zig");
const input = @import("input.zig");

extern fn consoleLog(arg: u32) void;

var state = game.emptyInit();

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
    state.prng = std.Random.DefaultPrng.init(seed);
    game.randomize(&state);
}
export fn drawCanvas() void {
    for (0..16) |x| {
        for (0..16) |y| {
            drawTile(state.background_buffer[x][y], x * 16, y * 16);
        }
    }

    for (0..16) |x| {
        for (0..16) |y| {
            if (state.foreground_buffer[x][y] != null) {
                drawTileOver(state.foreground_buffer[x][y].?, x * 16, y * 16);
            }
        }
    }

    const rand = state.prng.random();
    const j = std.meta.intToEnum(characters.Frame, rand.int(u8) % 3) catch .frame2;

    drawCharacterOver(characters.Character{ .direction = state.character_direction, .frame = j }, state.character_position.x * 16, state.character_position.y * 16);
}

export fn onInput(key: input.Key) void {
    const dire = input.toDirection(key);
    game.faceDirection(&state, dire);
    if (game.characterCanMove(&state, dire)) {
        state.character_position = coord.shiftXY(game.MAP_DIMS, dire, state.character_position);
        if (!game.isEmptySpace(&state, state.character_position)) {
            game.shiftObject(&state, dire, state.character_position);
        }
    }
}

fn drawTile(tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawReplace(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

fn drawTileOver(tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

fn drawCharacterOver(tile: characters.Character, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, characters.getCharacter(tile), x_pos, y_pos);
}

fn drawReplace(buffer: *[game.CANVAS_SIZE][game.CANVAS_SIZE][4]u8, tile: *const [16][16][4]u8, x_pos: usize, y_pos: usize) void {
    const tile_width = 16;
    for (0..tile_width) |x| {
        for (0..tile_width) |y| {
            buffer[y_pos + y][x_pos + x] = tile[x][y];
        }
    }
}

fn drawOver(buffer: *[game.CANVAS_SIZE][game.CANVAS_SIZE][4]u8, tile: *const [16][16][4]u8, x_pos: usize, y_pos: usize) void {
    const tile_width = 16;
    for (0..tile_width) |x| {
        for (0..tile_width) |y| {
            const a_o = tile[x][y][3];

            if (a_o > 0) {
                buffer[y_pos + y][x_pos + x][0] = tile[x][y][0];
                buffer[y_pos + y][x_pos + x][1] = tile[x][y][1];
                buffer[y_pos + y][x_pos + x][2] = tile[x][y][2];
                buffer[y_pos + y][x_pos + x][3] = tile[x][y][3];
            }
        }
    }
}

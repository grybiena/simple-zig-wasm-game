const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const game = @import("game.zig");

extern fn consoleLog(arg: u32) void;

var prng = std.Random.DefaultPrng.init(0);

const canvas_size: usize = 256;

// canvas_size * 2, where each pixel is 4 bytes (rgba)
var canvas_buffer = std.mem.zeroes(
    [canvas_size][canvas_size][4]u8,
);

var state = game.State{
    .character_position = game.Coord{ .x = 8, .y = 8 },
    .character_direction = .down,
    .background_buffer = std.mem.zeroes(
        [16][16]basictiles.BasicTile,
    ),
    .foreground_buffer = std.mem.zeroes(
        [16][16]?basictiles.BasicTile,
    ),
};

// The returned pointer will be used as an offset integer to the wasm memory
export fn getCanvasBufferPointer() [*]u8 {
    return @ptrCast(&canvas_buffer);
}

export fn getCanvasSize() usize {
    return canvas_size;
}

export fn seedRng(seed: u64) void {
    prng = std.Random.DefaultPrng.init(seed);
    state.background_buffer = game.randomFillTileBuffer(&prng);
    state.foreground_buffer = game.randomFillObjectBuffer(&prng);
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

    const rand = prng.random();
    const j = std.meta.intToEnum(characters.Frame, rand.int(u8) % 3) catch .frame2;

    drawCharacterOver(characters.Character{ .direction = state.character_direction, .frame = j }, state.character_position.x * 16, state.character_position.y * 16);
}

export fn onInput(input: Input) void {
    faceDirection(input);
    if (canMove(input)) {
        state.character_position = shiftCoord(input, state.character_position);
        if (!isEmptySpace(state.character_position)) {
            shiftObject(input, state.character_position);
        }
    }
}

fn drawTile(tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawReplace(&canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

fn drawTileOver(tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawOver(&canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

fn drawCharacterOver(tile: characters.Character, x_pos: usize, y_pos: usize) void {
    drawOver(&canvas_buffer, characters.getCharacter(tile), x_pos, y_pos);
}

fn drawReplace(buffer: *[canvas_size][canvas_size][4]u8, tile: *const [16][16][4]u8, x_pos: usize, y_pos: usize) void {
    const tile_width = 16;
    for (0..tile_width) |x| {
        for (0..tile_width) |y| {
            buffer[y_pos + y][x_pos + x] = tile[x][y];
        }
    }
}

fn drawOver(buffer: *[canvas_size][canvas_size][4]u8, tile: *const [16][16][4]u8, x_pos: usize, y_pos: usize) void {
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

const Input = enum(u32) {
    up = 0,
    down = 1,
    left = 2,
    right = 3,
};

fn shiftNeg(i: u8) u8 {
    if (i == 0) {
        return 0;
    }
    return i - 1;
}

fn shiftPos(i: u8) u8 {
    if (i >= 15) {
        return 15;
    } else {
        return i + 1;
    }
}

fn shiftCoord(input: Input, coord: game.Coord) game.Coord {
    switch (input) {
        .up => {
            return game.Coord{ .x = coord.x, .y = shiftNeg(coord.y) };
        },
        .down => {
            return game.Coord{ .x = coord.x, .y = shiftPos(coord.y) };
        },
        .left => {
            return game.Coord{ .x = shiftNeg(coord.x), .y = coord.y };
        },
        .right => {
            return game.Coord{ .x = shiftPos(coord.x), .y = coord.y };
        },
    }
}

fn shiftObject(input: Input, coord: game.Coord) void {
    const dest = shiftCoord(input, coord);
    state.foreground_buffer[dest.x][dest.y] = state.foreground_buffer[coord.x][coord.y];
    state.foreground_buffer[coord.x][coord.y] = null;
}

fn isEmptySpace(coord: game.Coord) bool {
    return state.foreground_buffer[coord.x][coord.y] == null;
}

fn canMove(input: Input) bool {
    const dest = shiftCoord(input, state.character_position);
    if (std.meta.eql(dest, state.character_position)) {
        return false;
    }
    if (isEmptySpace(dest)) {
        return true;
    }
    const push_dest = shiftCoord(input, dest);
    if (isEmptySpace(push_dest)) {
        return true;
    }
    return false;
}

fn faceDirection(input: Input) void {
    switch (input) {
        .up => {
            state.character_direction = .up;
        },
        .down => {
            state.character_direction = .down;
        },
        .left => {
            state.character_direction = .left;
        },
        .right => {
            state.character_direction = .right;
        },
    }
}

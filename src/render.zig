const game = @import("game.zig");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");

const CANVAS_SIZE = game.CANVAS_SIZE;

pub fn drawTile(state: *game.State, tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawReplace(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

pub fn drawTileOver(state: *game.State, tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

pub fn drawCharacterOver(state: *game.State, tile: characters.Character, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, characters.getCharacter(tile), x_pos, y_pos);
}

fn drawReplace(buffer: *[CANVAS_SIZE][CANVAS_SIZE][4]u8, tile: *const [16][16][4]u8, x_pos: usize, y_pos: usize) void {
    const tile_width = 16;
    for (0..tile_width) |x| {
        for (0..tile_width) |y| {
            buffer[y_pos + y][x_pos + x] = tile[x][y];
        }
    }
}

fn drawOver(buffer: *[CANVAS_SIZE][CANVAS_SIZE][4]u8, tile: *const [16][16][4]u8, x_pos: usize, y_pos: usize) void {
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

const game = @import("game.zig");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const object = @import("object.zig");

const CANVAS_SIZE = game.CANVAS_SIZE;

pub fn drawTile(state: *game.State, tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawReplace(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

pub fn drawObject(state: *game.State, o: object.Object, x_pos: usize, y_pos: usize) void {
    switch (o) {
        .character => |c| drawCharacter(state, c, x_pos, y_pos),
        .pushable => |p| drawPushable(state, p, x_pos, y_pos),
        .static => |s| drawStatic(state, s, x_pos, y_pos),
        .goal => |g| drawGoal(state, g, x_pos, y_pos),
    }
}

fn drawCharacter(state: *game.State, c: object.Character, x_pos: usize, y_pos: usize) void {
    const t = characters.Character{ .identity = c.sprite, .direction = c.direction, .frame = .frame2 };
    drawOver(&state.canvas_buffer, characters.getCharacter(t), x_pos, y_pos);
}

fn drawPushable(state: *game.State, _: object.Pushable, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, basictiles.getBasicTile(.pot), x_pos, y_pos);
}

fn drawStatic(state: *game.State, _: object.Static, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, basictiles.getBasicTile(.shrub), x_pos, y_pos);
}

fn drawGoal(state: *game.State, g: object.Goal, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, basictiles.getBasicTile(.patch), x_pos, y_pos);
    switch (g) {
        .empty => {},
        .filled => {
            drawOver(&state.canvas_buffer, basictiles.getBasicTile(.pot), x_pos, y_pos);
        },
    }
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

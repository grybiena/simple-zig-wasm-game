const std = @import("std");

const pixel_width = width * 16;
const pixel_height = height * 16;
pub const width = 12;
pub const height = 8;

const data = @embedFile("assets/characters.bin");

fn getTile(tile_x: usize, tile_y: usize) [16][16][4]u8 {
    @setEvalBranchQuota(1000000);
    var tile_buffer = std.mem.zeroes(
        [16][16][4]u8,
    );
    const tile_width = 16;
    for (0..tile_width) |x| {
        for (0..tile_width) |y| {
            tile_buffer[x][y][0] = data[4 * (tile_x * tile_width + x + pixel_width * (y + tile_width * tile_y))];
            tile_buffer[x][y][1] = data[4 * (tile_x * tile_width + x + pixel_width * (y + tile_width * tile_y)) + 1];
            tile_buffer[x][y][2] = data[4 * (tile_x * tile_width + x + pixel_width * (y + tile_width * tile_y)) + 2];
            tile_buffer[x][y][3] = data[4 * (tile_x * tile_width + x + pixel_width * (y + tile_width * tile_y)) + 3];
        }
    }
    return tile_buffer;
}

fn getTiles() [width][height][16][16][4]u8 {
    var tile_buffer = std.mem.zeroes(
        [width][height][16][16][4]u8,
    );
    for (0..height) |y| {
        for (0..width) |x| {
            tile_buffer[x][y] = getTile(x, y);
        }
    }
    return tile_buffer;
}

pub const characters = getTiles();

pub const Character = struct {
    direction: Direction,
    frame: Frame,
};

pub const Direction = enum {
    down,
    left,
    right,
    up,
};

pub const Frame = enum {
    frame1,
    frame2,
    frame3,
};

pub fn getCharacter(tile: Character) *const [16][16][4]u8 {
    return &character[@intFromEnum(tile.frame)][@intFromEnum(tile.direction)];
}

const character = bakeCharacter();

fn bakeCharacter() [std.enums.directEnumArrayLen(Frame, 0)][std.enums.directEnumArrayLen(Direction, 0)][16][16][4]u8 {
    var buffer = std.mem.zeroes(
        [std.enums.directEnumArrayLen(Frame, 0)][std.enums.directEnumArrayLen(Direction, 0)][16][16][4]u8,
    );
    for (std.enums.values(Frame)) |frame| {
        for (std.enums.values(Direction)) |direction| {
            const f = @intFromEnum(frame);
            const d = @intFromEnum(direction);
            buffer[f][d] = characters[@as(u8, f) + 6][d];
        }
    }

    return buffer;
}

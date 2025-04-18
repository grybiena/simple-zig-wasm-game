const std = @import("std");

const pixel_width = 128;
const pixel_height = 240;
pub const width = 8;
pub const height = 15;

const data = @embedFile("assets/basictiles.bin");

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

pub const basictiles = getTiles();

pub const BasicTile = enum {
    grass1,
    grass2,
    grass3,
    grass4,
    shrub1,
    stone1,
    pot,
};

pub fn getBasicTile(tile: BasicTile) *const [16][16][4]u8 {
    return switch (tile) {
        .grass1 => &basictiles[3][1],
        .grass2 => &basictiles[4][1],
        .grass3 => &basictiles[0][8],
        .grass4 => &basictiles[1][8],
        .shrub1 => &basictiles[4][2],
        .stone1 => &basictiles[1][9],
        .pot => &basictiles[3][3],
    };
}

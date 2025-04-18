const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");

pub const Coord = struct { x: u8, y: u8 };

pub const map_width = 16;
pub const map_height = 16;

pub const State = struct {
    character_position: Coord,
    character_direction: characters.Direction,
    background_buffer: [map_width][map_height]basictiles.BasicTile,
    foreground_buffer: [map_width][map_height]?basictiles.BasicTile,
};

pub fn emptyInit() State {
    return State{
        .character_position = Coord{ .x = 8, .y = 8 },
        .character_direction = .down,
        .background_buffer = std.mem.zeroes(
            [map_width][map_height]basictiles.BasicTile,
        ),
        .foreground_buffer = std.mem.zeroes(
            [map_width][map_height]?basictiles.BasicTile,
        ),
    };
}

pub fn randomInit(prng: *std.Random.DefaultPrng) State {
    return State{
        .character_position = Coord{ .x = 8, .y = 8 },
        .character_direction = .down,
        .background_buffer = randomFillTileBuffer(prng),
        .foreground_buffer = randomFillObjectBuffer(prng),
    };
}

pub fn randomFillObjectBuffer(prng: *std.Random.DefaultPrng) [map_width][map_height]?basictiles.BasicTile {
    const rand = prng.random();
    var buffer = std.mem.zeroes(
        [map_width][map_height]?basictiles.BasicTile,
    );
    for (0..10) |_| {
        const cx = rand.int(u8) % map_width;
        const cy = rand.int(u8) % map_height;
        const i = rand.int(u8) % 2;
        if (i == 0) {
            buffer[cx][cy] = .shrub1;
        } else {
            buffer[cx][cy] = .pot;
        }
    }
    return buffer;
}

pub fn randomFillTileBuffer(prng: *std.Random.DefaultPrng) [map_width][map_height]basictiles.BasicTile {
    const rand = prng.random();
    var buffer = std.mem.zeroes(
        [map_width][map_height]basictiles.BasicTile,
    );
    for (0..map_width) |x| {
        for (0..map_height) |y| {
            const grass = rand.int(u8) % 4;
            if (grass == 0) {
                buffer[x][y] = .grass1;
            } else if (grass == 1) {
                buffer[x][y] = .grass2;
            } else if (grass == 2) {
                buffer[x][y] = .grass3;
            } else {
                buffer[x][y] = .grass4;
            }
        }
    }
    return buffer;
}

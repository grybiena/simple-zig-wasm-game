const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");

pub const Coord = struct { x: u8, y: u8 };

pub const State = struct {
    character_position: Coord,
    character_direction: characters.Direction,
    background_buffer: [16][16]basictiles.BasicTile,
    foreground_buffer: [16][16]?basictiles.BasicTile,
};

pub fn randomFillObjectBuffer(prng: *std.Random.DefaultPrng) [16][16]?basictiles.BasicTile {
    const rand = prng.random();
    var buffer = std.mem.zeroes(
        [16][16]?basictiles.BasicTile,
    );
    for (0..10) |_| {
        const cx = rand.int(u8) % 16;
        const cy = rand.int(u8) % 16;
        const i = rand.int(u8) % 2;
        if (i == 0) {
            buffer[cx][cy] = .shrub1;
        } else {
            buffer[cx][cy] = .pot;
        }
    }
    return buffer;
}

pub fn randomFillTileBuffer(prng: *std.Random.DefaultPrng) [16][16]basictiles.BasicTile {
    const rand = prng.random();
    var buffer = std.mem.zeroes(
        [16][16]basictiles.BasicTile,
    );
    for (0..16) |x| {
        for (0..16) |y| {
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

const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const direction = @import("direction.zig");
const dimensions = @import("dimensions.zig");
const coord = @import("coord.zig");

pub const map_dims = dimensions.WH{ .w = 16, .h = 16 };

pub const State = struct {
    character_position: coord.XY,
    character_direction: direction.XY,
    background_buffer: [map_dims.w][map_dims.h]basictiles.BasicTile,
    foreground_buffer: [map_dims.w][map_dims.h]?basictiles.BasicTile,
};

pub fn emptyInit() State {
    return State{
        .character_position = coord.XY{ .x = 8, .y = 8 },
        .character_direction = .down,
        .background_buffer = std.mem.zeroes(
            [map_dims.w][map_dims.h]basictiles.BasicTile,
        ),
        .foreground_buffer = std.mem.zeroes(
            [map_dims.w][map_dims.h]?basictiles.BasicTile,
        ),
    };
}

pub fn randomInit(prng: *std.Random.DefaultPrng) State {
    return State{
        .character_position = coord.XY{ .x = 8, .y = 8 },
        .character_direction = .down,
        .background_buffer = randomFillTileBuffer(prng),
        .foreground_buffer = randomFillObjectBuffer(prng),
    };
}

pub fn randomFillObjectBuffer(prng: *std.Random.DefaultPrng) [map_dims.w][map_dims.h]?basictiles.BasicTile {
    const rand = prng.random();
    var buffer = std.mem.zeroes(
        [map_dims.w][map_dims.h]?basictiles.BasicTile,
    );
    for (0..10) |_| {
        const cx = rand.int(u8) % map_dims.w;
        const cy = rand.int(u8) % map_dims.h;
        const i = rand.int(u8) % 2;
        if (i == 0) {
            buffer[cx][cy] = .shrub1;
        } else {
            buffer[cx][cy] = .pot;
        }
    }
    return buffer;
}

pub fn randomFillTileBuffer(prng: *std.Random.DefaultPrng) [map_dims.w][map_dims.h]basictiles.BasicTile {
    const rand = prng.random();
    var buffer = std.mem.zeroes(
        [map_dims.w][map_dims.h]basictiles.BasicTile,
    );
    for (0..map_dims.w) |x| {
        for (0..map_dims.h) |y| {
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

pub fn shiftObject(st: *State, dire: direction.XY, pos: coord.XY) void {
    const dest = coord.shiftXY(map_dims, dire, pos);
    st.foreground_buffer[dest.x][dest.y] = st.foreground_buffer[pos.x][pos.y];
    st.foreground_buffer[pos.x][pos.y] = null;
}

pub fn isEmptySpace(st: *State, pos: coord.XY) bool {
    return st.foreground_buffer[pos.x][pos.y] == null;
}

pub fn characterCanMove(st: *State, dire: direction.XY) bool {
    const dest = coord.shiftXY(map_dims, dire, st.character_position);
    if (std.meta.eql(dest, st.character_position)) {
        return false;
    }
    if (isEmptySpace(st, dest)) {
        return true;
    }
    const push_dest = coord.shiftXY(map_dims, dire, dest);
    if (isEmptySpace(st, push_dest)) {
        return true;
    }
    return false;
}

pub fn faceDirection(st: *State, dire: direction.XY) void {
    st.character_direction = dire;
}

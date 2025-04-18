const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const direction = @import("direction.zig");
const dimensions = @import("dimensions.zig");
const coord = @import("coord.zig");

pub const MAP_DIMS = dimensions.WH{ .w = 16, .h = 16 };
pub const CANVAS_SIZE: usize = @as(usize, MAP_DIMS.w) * @as(usize, MAP_DIMS.h);

pub const State = struct {
    prng: std.Random.DefaultPrng,
    canvas_buffer: [CANVAS_SIZE][CANVAS_SIZE][4]u8,
    character_position: coord.XY,
    character_direction: direction.XY,
    background_buffer: [MAP_DIMS.w][MAP_DIMS.h]basictiles.BasicTile,
    foreground_buffer: [MAP_DIMS.w][MAP_DIMS.h]?basictiles.BasicTile,

    pub fn new() State {
        return emptyInit();
    }

    pub fn seed(self: *State, s: u64) void {
        self.prng = std.Random.DefaultPrng.init(s);
    }

    pub fn randomize(self: *State) void {
        randomFillTileBuffer(self);
        randomFillObjectBuffer(self);
    }

    pub fn render(self: *State) void {
        for (0..MAP_DIMS.w) |x| {
            for (0..MAP_DIMS.h) |y| {
                drawTile(self, self.background_buffer[x][y], x * 16, y * 16);
            }
        }

        for (0..MAP_DIMS.w) |x| {
            for (0..MAP_DIMS.h) |y| {
                if (self.foreground_buffer[x][y] != null) {
                    drawTileOver(self, self.foreground_buffer[x][y].?, x * 16, y * 16);
                }
            }
        }

        const rand = self.prng.random();
        const j = std.meta.intToEnum(characters.Frame, rand.int(u8) % 3) catch .frame2;

        drawCharacterOver(self, characters.Character{ .direction = self.character_direction, .frame = j }, self.character_position.x * 16, self.character_position.y * 16);
    }

    pub fn move(self: *State, dire: direction.XY) void {
        faceDirection(self, dire);
        if (characterCanMove(self, dire)) {
            self.character_position = coord.shiftXY(MAP_DIMS, dire, self.character_position);
            if (!isEmptySpace(self, self.character_position)) {
                shiftObject(self, dire, self.character_position);
            }
        }
    }
};

fn emptyInit() State {
    return State{
        .prng = std.Random.DefaultPrng.init(0),
        .canvas_buffer = std.mem.zeroes(
            [CANVAS_SIZE][CANVAS_SIZE][4]u8,
        ),
        .character_position = coord.XY{ .x = 8, .y = 8 },
        .character_direction = .down,
        .background_buffer = std.mem.zeroes(
            [MAP_DIMS.w][MAP_DIMS.h]basictiles.BasicTile,
        ),
        .foreground_buffer = std.mem.zeroes(
            [MAP_DIMS.w][MAP_DIMS.h]?basictiles.BasicTile,
        ),
    };
}

// initialization

fn randomFillObjectBuffer(state: *State) void {
    const rand = state.prng.random();
    state.foreground_buffer = std.mem.zeroes(
        [MAP_DIMS.w][MAP_DIMS.h]?basictiles.BasicTile,
    );
    for (0..10) |_| {
        const cx = rand.int(u8) % MAP_DIMS.w;
        const cy = rand.int(u8) % MAP_DIMS.h;
        const i = rand.int(u8) % 2;
        if (i == 0) {
            state.foreground_buffer[cx][cy] = .shrub1;
        } else {
            state.foreground_buffer[cx][cy] = .pot;
        }
    }
}

pub fn randomFillTileBuffer(state: *State) void {
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

// movement

pub fn shiftObject(st: *State, dire: direction.XY, pos: coord.XY) void {
    const dest = coord.shiftXY(MAP_DIMS, dire, pos);
    st.foreground_buffer[dest.x][dest.y] = st.foreground_buffer[pos.x][pos.y];
    st.foreground_buffer[pos.x][pos.y] = null;
}

pub fn isEmptySpace(st: *State, pos: coord.XY) bool {
    return st.foreground_buffer[pos.x][pos.y] == null;
}

pub fn characterCanMove(st: *State, dire: direction.XY) bool {
    const dest = coord.shiftXY(MAP_DIMS, dire, st.character_position);
    if (std.meta.eql(dest, st.character_position)) {
        return false;
    }
    if (isEmptySpace(st, dest)) {
        return true;
    }
    const push_dest = coord.shiftXY(MAP_DIMS, dire, dest);
    if (isEmptySpace(st, push_dest)) {
        return true;
    }
    return false;
}

pub fn faceDirection(st: *State, dire: direction.XY) void {
    st.character_direction = dire;
}

// drawing

fn drawTile(state: *State, tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawReplace(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

fn drawTileOver(state: *State, tile: basictiles.BasicTile, x_pos: usize, y_pos: usize) void {
    drawOver(&state.canvas_buffer, basictiles.getBasicTile(tile), x_pos, y_pos);
}

fn drawCharacterOver(state: *State, tile: characters.Character, x_pos: usize, y_pos: usize) void {
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

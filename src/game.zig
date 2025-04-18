const std = @import("std");
const basictiles = @import("basictiles.zig");
const characters = @import("characters.zig");
const direction = @import("direction.zig");
const dimension = @import("dimension.zig");
const position = @import("position.zig");
const render = @import("render.zig");
const initialize = @import("initialize.zig");
const generate = @import("generate.zig");
const movement = @import("movement.zig");

pub const MAP_DIMS = dimension.WH{ .w = 16, .h = 16 };
pub const CANVAS_SIZE: usize = @as(usize, MAP_DIMS.w) * @as(usize, MAP_DIMS.h);

pub const State = struct {
    prng: std.Random.DefaultPrng,
    canvas_buffer: [CANVAS_SIZE][CANVAS_SIZE][4]u8,
    character_position: position.XY,
    character_direction: direction.XY,
    background_buffer: [MAP_DIMS.w][MAP_DIMS.h]basictiles.BasicTile,
    foreground_buffer: [MAP_DIMS.w][MAP_DIMS.h]?basictiles.BasicTile,

    pub fn new() State {
        return initialize.empty();
    }

    pub fn seed(self: *State, s: u64) void {
        self.prng = std.Random.DefaultPrng.init(s);
    }

    pub fn randomize(self: *State) void {
        generate.randomFillTileBuffer(self);
        generate.randomFillObjectBuffer(self);
    }

    pub fn draw(self: *State) void {
        for (0..MAP_DIMS.w) |x| {
            for (0..MAP_DIMS.h) |y| {
                render.drawTile(self, self.background_buffer[x][y], x * 16, y * 16);
            }
        }

        for (0..MAP_DIMS.w) |x| {
            for (0..MAP_DIMS.h) |y| {
                if (self.foreground_buffer[x][y] != null) {
                    render.drawTileOver(self, self.foreground_buffer[x][y].?, x * 16, y * 16);
                }
            }
        }

        const rand = self.prng.random();
        const j = std.meta.intToEnum(characters.Frame, rand.int(u8) % 3) catch .frame2;

        render.drawCharacterOver(self, characters.Character{ .direction = self.character_direction, .frame = j }, self.character_position.x * 16, self.character_position.y * 16);
    }

    pub fn move(self: *State, dire: direction.XY) void {
        movement.faceDirection(self, dire);
        if (movement.characterCanMove(self, dire)) {
            self.character_position = position.shiftXY(MAP_DIMS, dire, self.character_position);
            if (!movement.isEmptySpace(self, self.character_position)) {
                movement.shiftObject(self, dire, self.character_position);
            }
        }
    }
};

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
const object = @import("object.zig");

pub const MAP_DIMS = dimension.WH{ .w = 16, .h = 16 };
pub const CANVAS_SIZE: usize = @as(usize, MAP_DIMS.w) * @as(usize, MAP_DIMS.h);

pub const State = struct {
    prng: std.Random.DefaultPrng,
    canvas_buffer: [CANVAS_SIZE][CANVAS_SIZE][4]u8,
    background_buffer: [MAP_DIMS.w][MAP_DIMS.h]basictiles.BasicTile,
    goal_buffer: [MAP_DIMS.w][MAP_DIMS.h]bool,
    object_buffer: [MAP_DIMS.w][MAP_DIMS.h]?object.Object,

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
                if (self.goal_buffer[x][y]) {
                    render.drawGoal(self, x * 16, y * 16);
                }
            }
        }

        for (0..MAP_DIMS.w) |x| {
            for (0..MAP_DIMS.h) |y| {
                if (self.object_buffer[x][y] != null) {
                    render.drawObject(self, self.object_buffer[x][y].?, x * 16, y * 16);
                }
            }
        }
    }

    pub fn move(self: *State, dire: direction.XY) void {
        movement.faceDirection(self, dire);
        if (movement.characterCanMove(self, dire)) {
            const cur_ada_position = movement.adaPosition(self);
            const new_ada_position = position.shiftXY(MAP_DIMS, dire, cur_ada_position);
            if (!movement.isEmptySpace(self, new_ada_position)) {
                movement.shiftObject(self, dire, new_ada_position);
            }
            movement.shiftObject(self, dire, cur_ada_position);
        }
    }
};

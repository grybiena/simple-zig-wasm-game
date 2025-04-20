const characters = @import("characters.zig");
const direction = @import("direction.zig");
const position = @import("position.zig");

pub const Category = enum { character, pushable, static, goal };

pub const Pushable = enum { pot };

pub const Static = enum { shrub };

pub const Goal = enum { empty, filled };

pub const Character = struct {
    sprite: characters.Identity,
    direction: direction.XY,
};

pub const Object = union(Category) { character: Character, pushable: Pushable, static: Static, goal: Goal };

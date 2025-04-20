const characters = @import("characters.zig");
const direction = @import("direction.zig");
const position = @import("position.zig");

pub const Category = enum { character, pushable, static };

pub const Pushable = enum { pot };

pub const Static = enum { shrub };

pub const Character = struct {
    sprite: characters.Identity,
    direction: direction.XY,
};

pub const Object = union(Category) { character: Character, pushable: Pushable, static: Static };

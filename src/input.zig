const direction = @import("direction.zig");

pub const Key = enum(u32) {
    down = 0,
    left = 1,
    right = 2,
    up = 3,
};

pub fn toDirection(key: Key) direction.XY {
    return switch (key) {
        .down => .down,
        .left => .left,
        .right => .right,
        .up => .up,
    };
}

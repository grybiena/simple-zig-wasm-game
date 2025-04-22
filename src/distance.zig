const position = @import("position.zig");

pub fn manhattan(from: position.XY, to: position.XY) u8 {
    return @abs(from.x - to.x) + @abs(from.y + to.y);
}

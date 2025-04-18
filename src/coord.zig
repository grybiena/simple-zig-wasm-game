const direction = @import("direction.zig");
const dimensions = @import("dimensions.zig");
pub const XY = struct { x: u8, y: u8 };

pub fn shiftXY(boundary: dimensions.WH, toward: direction.XY, position: XY) XY {
    switch (toward) {
        .up => {
            return XY{ .x = position.x, .y = shiftNeg(position.y) };
        },
        .down => {
            return XY{ .x = position.x, .y = shiftPos(position.y, boundary.h) };
        },
        .left => {
            return XY{ .x = shiftNeg(position.x), .y = position.y };
        },
        .right => {
            return XY{ .x = shiftPos(position.x, boundary.w), .y = position.y };
        },
    }
}

fn shiftNeg(i: u8) u8 {
    if (i == 0) {
        return 0;
    }
    return i - 1;
}

fn shiftPos(i: u8, limit: u8) u8 {
    if (i >= limit - 1) {
        return limit - 1;
    } else {
        return i + 1;
    }
}

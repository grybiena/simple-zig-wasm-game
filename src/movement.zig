const std = @import("std");
const game = @import("game.zig");
const direction = @import("direction.zig");
const position = @import("position.zig");
const object = @import("object.zig");

const CANVAS_SIZE = game.CANVAS_SIZE;
const MAP_DIMS = game.MAP_DIMS;

pub fn shiftObject(st: *game.State, dire: direction.XY, pos: position.XY) void {
    const dest = position.shiftXY(MAP_DIMS, dire, pos);
    st.object_buffer[dest.x][dest.y] = st.object_buffer[pos.x][pos.y];
    st.object_buffer[pos.x][pos.y] = null;
}

pub fn isEmptySpace(st: *game.State, pos: position.XY) bool {
    return st.object_buffer[pos.x][pos.y] == null;
}

pub fn isPushable(st: *game.State, pos: position.XY) bool {
    if (st.object_buffer[pos.x][pos.y] == null) return false;
    switch (st.object_buffer[pos.x][pos.y].?) {
        .pushable => |_| return true,
        else => return false,
    }
}

pub fn isTom(st: *game.State, pos: position.XY) bool {
    if (st.object_buffer[pos.x][pos.y] == null) return false;
    switch (st.object_buffer[pos.x][pos.y].?) {
        .character => |c| switch (c.sprite) {
            .tom => return true,
            else => return false,
        },
        else => return false,
    }
}

pub fn isPot(st: *game.State, pos: position.XY) bool {
    if (st.object_buffer[pos.x][pos.y] == null) return false;
    switch (st.object_buffer[pos.x][pos.y].?) {
        .pushable => |_| return true,
        else => return false,
    }
}

// TODO extract all relevant info into struct in one pass
pub fn adaPosition(st: *game.State) position.XY {
    for (0..MAP_DIMS.w) |x| {
        for (0..MAP_DIMS.h) |y| {
            const o = st.object_buffer[x][y];
            if (o == null) continue;
            switch (o.?) {
                .character => |c| {
                    if (c.sprite == .ada) {
                        return position.XY{ .x = @intCast(x), .y = @intCast(y) };
                    }
                },
                else => continue,
            }
        }
    }
    //TODO error state using error return path
    unreachable;
}

pub fn characterCanMove(st: *game.State, dire: direction.XY) bool {
    const ada_pos = adaPosition(st);
    const dest = position.shiftXY(MAP_DIMS, dire, ada_pos);
    if (std.meta.eql(dest, ada_pos)) {
        return false;
    }
    if (isEmptySpace(st, dest) or isTom(st, dest)) {
        return true;
    }
    if (!isPushable(st, dest)) {
        return false;
    }
    const push_dest = position.shiftXY(MAP_DIMS, dire, dest);
    if (isEmptySpace(st, push_dest)) {
        return true;
    }
    return false;
}

pub fn faceDirection(st: *game.State, dire: direction.XY) void {
    const ada_pos = adaPosition(st);
    st.object_buffer[ada_pos.x][ada_pos.y] = object.Object{ .character = object.Character{ .sprite = .ada, .direction = dire } };
}

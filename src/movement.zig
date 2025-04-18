const std = @import("std");
const game = @import("game.zig");
const direction = @import("direction.zig");
const position = @import("position.zig");

const CANVAS_SIZE = game.CANVAS_SIZE;
const MAP_DIMS = game.MAP_DIMS;

pub fn shiftObject(st: *game.State, dire: direction.XY, pos: position.XY) void {
    const dest = position.shiftXY(MAP_DIMS, dire, pos);
    st.foreground_buffer[dest.x][dest.y] = st.foreground_buffer[pos.x][pos.y];
    st.foreground_buffer[pos.x][pos.y] = null;
}

pub fn isEmptySpace(st: *game.State, pos: position.XY) bool {
    return st.foreground_buffer[pos.x][pos.y] == null;
}

pub fn characterCanMove(st: *game.State, dire: direction.XY) bool {
    const dest = position.shiftXY(MAP_DIMS, dire, st.character_position);
    if (std.meta.eql(dest, st.character_position)) {
        return false;
    }
    if (isEmptySpace(st, dest)) {
        return true;
    }
    const push_dest = position.shiftXY(MAP_DIMS, dire, dest);
    if (isEmptySpace(st, push_dest)) {
        return true;
    }
    return false;
}

pub fn faceDirection(st: *game.State, dire: direction.XY) void {
    st.character_direction = dire;
}

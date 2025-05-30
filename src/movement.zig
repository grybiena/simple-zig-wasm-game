const std = @import("std");
const game = @import("game.zig");
const direction = @import("direction.zig");
const position = @import("position.zig");
const object = @import("object.zig");
const characters = @import("characters.zig");
const distance = @import("distance.zig");

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

pub fn isAda(st: *game.State, pos: position.XY) bool {
    if (st.object_buffer[pos.x][pos.y] == null) return false;
    switch (st.object_buffer[pos.x][pos.y].?) {
        .character => |c| switch (c.sprite) {
            .ada => return true,
            else => return false,
        },
        else => return false,
    }
}

pub fn tomMove(st: *game.State) direction.XY {
    const tom_goal = tomGoal(st);
    const tom_pos = characterPosition(st, .tom);
    const dx: i16 = @as(i16, tom_goal.x) - @as(i16, tom_pos.x);
    const dy: i16 = @as(i16, tom_goal.y) - @as(i16, tom_pos.y);
    if (@abs(dx) > @abs(dy)) {
        if (dx > 0) {
            return .right;
        }
        return .left;
    }
    if (dy > 0) {
        return .down;
    }
    return .up;
}

fn tomGoal(st: *game.State) position.XY {
    const tom_pos = characterPosition(st, .tom);
    var goal_pos: ?position.XY = null;
    for (0..MAP_DIMS.w) |x| {
        for (0..MAP_DIMS.h) |y| {
            const o = st.object_buffer[x][y];
            if (o == null) continue;
            switch (o.?) {
                .pushable => |_| {
                    if (st.goal_buffer[x][y]) {
                        const pot_pos = position.XY{ .x = @intCast(x), .y = @intCast(y) };
                        if (goal_pos == null or distance.manhattan(tom_pos, pot_pos) < distance.manhattan(tom_pos, goal_pos.?)) {
                            goal_pos = pot_pos;
                        }
                    }
                },
                else => continue,
            }
        }
    }
    if (goal_pos != null) return goal_pos.?;
    return characterPosition(st, .ada);
}

pub fn isPot(st: *game.State, pos: position.XY) bool {
    if (st.object_buffer[pos.x][pos.y] == null) return false;
    switch (st.object_buffer[pos.x][pos.y].?) {
        .pushable => |_| return true,
        else => return false,
    }
}

// TODO extract all relevant info into struct in one pass
pub fn characterPosition(st: *game.State, who: characters.Identity) position.XY {
    for (0..MAP_DIMS.w) |x| {
        for (0..MAP_DIMS.h) |y| {
            const o = st.object_buffer[x][y];
            if (o == null) continue;
            switch (o.?) {
                .character => |c| {
                    if (c.sprite == who) {
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

pub fn characterCanMove(st: *game.State, who: characters.Identity, dire: direction.XY) bool {
    const ada_pos = characterPosition(st, who);
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

pub fn faceDirection(st: *game.State, who: characters.Identity, dire: direction.XY) void {
    const ada_pos = characterPosition(st, who);
    st.object_buffer[ada_pos.x][ada_pos.y] = object.Object{ .character = object.Character{ .sprite = who, .direction = dire } };
}

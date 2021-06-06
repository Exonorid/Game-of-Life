const gol = @import("gol.zig");
const Board = gol.Board;
const std = @import("std");

pub const glider = comptime parse_pattern(
    \\ @
    \\  @
    \\@@@
);
pub const glider_gun = comptime parse_pattern(
    \\                        @
    \\                      @ @
    \\            @@      @@            @@
    \\           @   @    @@            @@
    \\@@        @     @   @@
    \\@@        @   @ @@    @ @
    \\          @     @       @
    \\           @   @
    \\            @@
);
pub const lwss = comptime parse_pattern(
    \\ @  @
    \\@
    \\@   @
    \\@@@@
);
pub const mwss = comptime parse_pattern(
    \\   @
    \\ @   @
    \\@
    \\@    @
    \\@@@@@
);
pub const hwss = comptime parse_pattern(
    \\   @@
    \\ @    @
    \\@
    \\@     @
    \\@@@@@@
);
pub const coe_ship = comptime parse_pattern(
    \\    @@@@@@
    \\  @@     @
    \\@@ @     @
    \\    @   @
    \\      @
    \\      @@
    \\     @@@@
    \\     @@ @@
    \\       @@
);
pub const schick_engine = comptime parse_pattern(
    \\ @  @
    \\@
    \\@   @
    \\@@@@         @@
    \\      @@@     @@
    \\      @@ @@      @@@
    \\      @@@     @@
    \\@@@@         @@
    \\@   @
    \\@
    \\ @  @
);

pub fn parse_pattern(comptime pattern: []const u8) [][]const u8 {
    @setEvalBranchQuota(100000);
    const num_lines = blk: {
        var a = 1;
        for(pattern) |ch| {
            if(ch == '\n') a += 1;
        }
        break :blk a;
    };
    var out_arr = [_][]u8{undefined} ** num_lines;
    var i = 0;
    var iter = std.mem.split(pattern, "\n");
    while(iter.next()) |line| : (i += 1) {
        var out_line = [_]u8{undefined} ** line.len;
        for(line) |ch, j|
            out_line[j] = if(ch == ' ') 0 else 1;
        out_arr[i] = out_line[0..];
    }
    return out_arr[0..];
}

pub fn load_pattern(board: *Board, pattern: [][]const u8, centered: bool) void {
    const pat_width = blk: {
        var l: usize = 0;
        for(pattern) |line| {
            l = std.math.max(l, line.len);
        }
        break :blk l;
    };
    const pat_height = pattern.len;
    const x_off = if(centered) (gol.width >> 1) - (pat_width >> 1) else 0;
    const y_off = if(centered) (gol.height >> 1) - (pat_height >> 1) else 0;
    for(pattern) |pat_line, y| {
        for(pat_line) |val, x| {
            board[y + y_off][x + x_off] = val;
        }
    }
}
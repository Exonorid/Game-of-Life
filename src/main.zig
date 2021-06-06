const std = @import("std");
const curses = @import("curses.zig");
const signal = @cImport({
    @cInclude("signal.h");
});
const gol = @import("gol.zig");
const patterns = @import("patterns.zig");

fn sighandler(signum: c_int) callconv(.C) void {
    if(signum == signal.SIGINT) {
        curses.endwin();
        if(num_updates > 0) {
            std.debug.print("Average update took {d:.3} ns\n", .{@intToFloat(f64, total_update_delta) / @intToFloat(f64, num_updates)});
        }
        std.debug.print("Buh bye!\n", .{});
        std.process.exit(0);
    }
}

//255, 0, 0
//127.5, 255, 0
//0, 255, 255
//127.5, 0, 255

var num_updates: u64 = 0;
var total_update_delta: u128 = 0;

pub fn main() void {
    curses.initscr();
    var win = curses.newwin(gol.height, gol.width, 0, 0);
    curses.noecho();
    curses.start_color();
    curses.curs_set(0);

    _ = signal.signal(signal.SIGINT, sighandler);

    var x: i32 = 0;
    var y: i32 = 0;

    const colors = [_][3]u8{
        [3]u8{  0,   0,   0},
        [3]u8{255, 255, 255},
        [3]u8{255,   0,   0},
        [3]u8{128, 255,   0},
        [3]u8{  0, 255, 255},
        [3]u8{128,   0, 255},
    };
    for(colors) |color, i| {
        var index = @truncate(u15, i);
        curses.initColor8B(index, color[0], color[1], color[2]);
        if(i > 0) curses.initPair(index - 1, index, 0);
    }

    var buffer_a = [_][gol.width]u8{
        [_]u8{0} ** gol.width
    } ** gol.height;
    var buffer_b = [_][gol.width]u8{
        [_]u8{0} ** gol.width
    } ** gol.height;

    var buffers = gol.BufferPair{
        .a = &buffer_a,
        .b = &buffer_b
    };

    patterns.load_pattern(buffers.a, patterns.schick_engine, true);

    while(true) {
        gol.print_board(buffers.a);
        std.time.sleep(100000000);
        var start_time = @intCast(u128, std.time.nanoTimestamp());
        buffers = gol.update_board(buffers);
        num_updates += 1;
        total_update_delta += @intCast(u128, std.time.nanoTimestamp()) - start_time;
    }
}

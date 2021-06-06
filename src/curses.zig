const c = @cImport(@cInclude("curses.h"));
const std = @import("std");

pub fn initscr() void {
    _ = c.initscr();
}

pub fn newwin(width: u32, height: u32, x: u32, y: u32) *c.WINDOW {
    return c.newwin(@intCast(c_int, height), @intCast(c_int, width), @intCast(c_int, y), @intCast(c_int, x));
}

pub fn noecho() void {
    _ = c.noecho();
}

pub fn start_color() void {
    _ = c.start_color();
}

pub fn curs_set(vis: u32) void {
    _ = c.curs_set(@intCast(c_int, vis));
}

pub fn endwin() void {
    _ = c.endwin();
}

pub fn erase() void {
    _ = c.erase();
}

pub fn refresh() void {
    _ = c.refresh();
}

pub fn initColor8B(i: u15, r: u8, g: u8, b: u8) void {
    var scaled_r = @truncate(u15, @divTrunc((@as(usize, r) * 999), 255));
    var scaled_g = @truncate(u15, @divTrunc((@as(usize, g) * 999), 255));
    var scaled_b = @truncate(u15, @divTrunc((@as(usize, b) * 999), 255));

    if(c.init_color(i, scaled_r, scaled_g, scaled_b) != c.OK)
        std.log.err("Could not initialize color #{} with #{x:0>2}{x:0>2}{x:0>2}", .{i, r, g, b});
}

pub fn initPair(i: u15, fg: u15, bg: u15) void {
    if(c.init_pair(i, fg, bg) != c.OK)
        std.log.err("Could not initialize color pair #{} with pair ({}, {})", .{i, fg, bg});
}

//This is where i gave up on error handling lol
pub fn echoColor(ch: u8, pair: u15) void {
    _ = c.echochar(@intCast(c_uint, ch | c.COLOR_PAIR(pair)));
}

pub fn move(y: u32, x: u32) void {
    _ = c.move(@intCast(c_int, y), @intCast(c_int, x));
}
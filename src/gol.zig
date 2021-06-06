const build_options = @import("build_options");
const curses = @import("curses.zig");

pub const width = 200;
pub const height = 30;

pub const Board = [height][width]u8;
pub const BufferPair = struct {
    a: *Board,
    b: *Board
};

pub fn update_board(buffers: BufferPair) BufferPair {
    var board = buffers.a;
    var buffer = buffers.b;
    for(buffer) |*row| {
        for(row) |*cell| {
            cell.* = 0;
        }
    }

    for(board) |row, y| {
        for(row) |cell, x| {
            const neighbors = blk: {
                var ct: u4 = 0;
                var c_x: u2 = 0;
                while(c_x <= 2) : (c_x += 1) {
                    var c_y: u2 = 0;
                    //Fragile spaghetti, do not touch
                    while(c_y <= 2) : (c_y += 1) {
                        if(c_x == 1 and c_y == 1) continue;
                        var n_x: usize = undefined;
                        var n_y: usize = undefined;
                        if(build_options.loop_around) {
                            n_x = x + c_x;
                            n_y = y + c_y;
                            if(n_x == 0) n_x = width;
                            if(n_x == width + 1) n_x = 1;
                            if(n_y == 0) n_y = height;
                            if(n_y == height + 1) n_y = 1;
                            n_x -= 1;
                            n_y -= 1;
                        } else {
                            if(c_x == 0 and x == 0 or
                            c_x == 2 and x == width - 1 or
                            c_y == 0 and y == 0 or
                            c_y == 2 and y == height - 1) {
                                continue;
                            }
                            n_x = x + c_x - 1;
                            n_y = y + c_y - 1;
                        }
                        ct += @as(u3, if(board[n_y][n_x] == 0) 0 else 1);
                    }
                }
                break :blk ct;
            };
            
            //Generate next generation
            if(cell > 0) { //alive
                if(neighbors == 2 or neighbors == 3) buffer[y][x] = (cell % 4) + 1;
            } else { //dead
                if(neighbors == 3) buffer[y][x] = 1;
            }
        }
    }
    return BufferPair{.a = buffer, .b = board};
}

pub fn print_board(board: *[height][width]u8) void {
    curses.erase();
    curses.refresh();
    for(board) |row, y| {
        for(row) |cell, x| {
            if(cell > 0) {
                curses.move(@truncate(u32, y), @truncate(u32, x));
                curses.echoColor('@', cell);
            }
        }
    }
}
const std = @import("std");
const mem = std.mem;
const print = std.debug.print;

const GRID_SIZE = 140;

pub fn idx(i: usize, j: usize) usize {
    return i * GRID_SIZE + j;
}

pub fn get(grid: []u8, i: usize, j: usize) u8 {
    return grid[idx(i, j)];
}

pub fn checkWord(grid: []u8, x1: usize, y1: usize, x2: usize, y2: usize, x3: usize, y3: usize, x4: usize, y4: usize) bool {
    return (get(grid, x1, y1) == 'X' and
        get(grid, x2, y2) == 'M' and
        get(grid, x3, y3) == 'A' and
        get(grid, x4, y4) == 'S') or
        (get(grid, x1, y1) == 'S' and
        get(grid, x2, y2) == 'A' and
        get(grid, x3, y3) == 'M' and
        get(grid, x4, y4) == 'X');
}

pub fn main() !void {
    const input = @embedFile("input");
    var it = std.mem.tokenizeAny(u8, input, "\n");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // Store all input in a grid (array of array)
    var grid = std.mem.zeroes([GRID_SIZE * GRID_SIZE]u8);

    var grid_row: usize = 0;
    while (it.next()) |line| {
        for (line, 0..) |c, grid_col| {
            if (c == '\r') {
                continue;
            }
            grid[grid_row * GRID_SIZE + grid_col] = c;
        }
        grid_row += 1;
    }

    var count_part1: u32 = 0;
    for (0..GRID_SIZE) |i| {
        for (0..GRID_SIZE - 3) |j| {
            if (checkWord(&grid, i, j, i, j + 1, i, j + 2, i, j + 3)) {
                count_part1 += 1;
            }
            if (checkWord(&grid, j, i, j + 1, i, j + 2, i, j + 3, i)) {
                count_part1 += 1;
            }
            if (i < GRID_SIZE - 3) {
                if (checkWord(&grid, i, j, i + 1, j + 1, i + 2, j + 2, i + 3, j + 3)) {
                    count_part1 += 1;
                }
                if (checkWord(&grid, i, j + 3, i + 1, j + 2, i + 2, j + 1, i + 3, j)) {
                    count_part1 += 1;
                }
            }
        }
    }
    var count_part2: u32 = 0;
    for (0..GRID_SIZE - 2) |i| {
        for (0..GRID_SIZE - 2) |j| {
            if (get(&grid, i + 1, j + 1) == 'A' and
                ((get(&grid, i, j) == 'M' and get(&grid, i + 2, j + 2) == 'S') or (get(&grid, i, j) == 'S' and get(&grid, i + 2, j + 2) == 'M')) and
                ((get(&grid, i, j + 2) == 'M' and get(&grid, i + 2, j) == 'S') or (get(&grid, i, j + 2) == 'S' and get(&grid, i + 2, j) == 'M')))
            {
                count_part2 += 1;
            }
        }
    }

    print("Part 1: {}\n", .{count_part1});
    print("Part 2: {}\n", .{count_part2});
}

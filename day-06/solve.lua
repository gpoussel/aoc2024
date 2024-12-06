local UP = "^"
local DOWN = "v"
local LEFT = "<"
local RIGHT = ">"
local WALL = "#"
local VISITED = "X"

local original_input = {}
local original_guard_position = {
    row = nil,
    col = nil,
    dir = nil
}
for line in io.lines("./input") do
    local row = {}
    for tile in string.gmatch(line, ".") do
        if (tile == UP or tile == DOWN or tile == LEFT or tile == RIGHT) then
            original_guard_position.row = #original_input + 1
            original_guard_position.col = #row + 1
            original_guard_position.dir = tile
        end
        table.insert(row, tile)
    end
    table.insert(original_input, row);
end

local function print_grid(grid)
    for i = 1, #grid do
        for j = 1, #grid[i] do
            io.write(grid[i][j])
        end
        io.write("\n")
    end
end

local function clone_grid(grid)
    local new_grid = {}
    for i = 1, #grid do
        new_grid[i] = {}
        for j = 1, #grid[i] do
            new_grid[i][j] = grid[i][j]
        end
    end
    return new_grid
end

local function get_guard_path(guard_position, input_grid, check_for_loops)
    local grid = clone_grid(input_grid)
    local visits = {}
    local obstacles_that_create_cycles = {}
    for i = 1, #grid do
        visits[i] = {}
        obstacles_that_create_cycles[i] = {}
        for j = 1, #grid[1] do
            visits[i][j] = {
                LEFT = false,
                RIGHT = false,
                UP = false,
                DOWN = false
            }
            obstacles_that_create_cycles[i][j] = 0
        end
    end
    local steps = 0
    local loop = false
    while true do
        if check_for_loops and steps % 1000 == 0 then
            print("Steps: ", steps)
        end
        if guard_position.row <= 0 or guard_position.row > #grid or guard_position.col <= 0 or guard_position.col >
            #grid[1] then
            break
        end
        if visits[guard_position.row][guard_position.col][guard_position.dir] then
            loop = true
            break
        end
        if guard_position.dir == UP then
            if guard_position.row > 1 and grid[guard_position.row - 1][guard_position.col] == WALL then
                guard_position.dir = RIGHT
                grid[guard_position.row][guard_position.col] = RIGHT
            else
                if visits[guard_position.row][guard_position.col].UP then
                    loop = true
                    break
                end
                visits[guard_position.row][guard_position.col].UP = true
                if guard_position.row > 0 and check_for_loops and
                    obstacles_that_create_cycles[guard_position.row - 1][guard_position.col] == 0 and
                    (guard_position.row - 1 ~= original_guard_position.row or guard_position.col ~=
                        original_guard_position.col) then

                    local grid_clone = clone_grid(input_grid)
                    grid_clone[guard_position.row - 1][guard_position.col] = WALL
                    local path_if_obstacle = get_guard_path({
                        row = original_guard_position.row,
                        col = original_guard_position.col,
                        dir = original_guard_position.dir
                    }, grid_clone)
                    if path_if_obstacle.loop then
                        obstacles_that_create_cycles[guard_position.row - 1][guard_position.col] = 1
                    else
                        obstacles_that_create_cycles[guard_position.row - 1][guard_position.col] = -1
                    end
                end
                if grid[guard_position.row][guard_position.col] ~= VISITED then
                    steps = steps + 1
                end
                grid[guard_position.row][guard_position.col] = VISITED
                guard_position.row = guard_position.row - 1
            end
        elseif guard_position.dir == DOWN then
            if guard_position.row < #grid and grid[guard_position.row + 1][guard_position.col] == WALL then
                guard_position.dir = LEFT
                grid[guard_position.row][guard_position.col] = LEFT
            else
                if visits[guard_position.row][guard_position.col].DOWN then
                    loop = true
                    break
                end
                visits[guard_position.row][guard_position.col].DOWN = true
                if guard_position.row < #grid and check_for_loops and
                    obstacles_that_create_cycles[guard_position.row + 1][guard_position.col] == 0 and
                    (guard_position.row + 1 ~= original_guard_position.row or guard_position.col ~=
                        original_guard_position.col) then

                    local grid_clone = clone_grid(input_grid)
                    grid_clone[guard_position.row + 1][guard_position.col] = WALL
                    local path_if_obstacle = get_guard_path({
                        row = original_guard_position.row,
                        col = original_guard_position.col,
                        dir = original_guard_position.dir
                    }, grid_clone)
                    if path_if_obstacle.loop then
                        obstacles_that_create_cycles[guard_position.row + 1][guard_position.col] = 1
                    else
                        obstacles_that_create_cycles[guard_position.row + 1][guard_position.col] = -1
                    end
                end
                if grid[guard_position.row][guard_position.col] ~= VISITED then
                    steps = steps + 1
                end
                grid[guard_position.row][guard_position.col] = VISITED
                guard_position.row = guard_position.row + 1
            end
        elseif guard_position.dir == LEFT then
            if guard_position.col > 1 and grid[guard_position.row][guard_position.col - 1] == WALL then
                guard_position.dir = UP
                grid[guard_position.row][guard_position.col] = UP
            else
                if visits[guard_position.row][guard_position.col].LEFT then
                    loop = true
                    break
                end
                visits[guard_position.row][guard_position.col].LEFT = true
                if guard_position.col > 0 and check_for_loops and
                    obstacles_that_create_cycles[guard_position.row][guard_position.col - 1] == 0 and
                    (guard_position.row ~= original_guard_position.row or guard_position.col - 1 ~=
                        original_guard_position.col) then

                    local grid_clone = clone_grid(input_grid)
                    grid_clone[guard_position.row][guard_position.col - 1] = WALL
                    local path_if_obstacle = get_guard_path({
                        row = original_guard_position.row,
                        col = original_guard_position.col,
                        dir = original_guard_position.dir
                    }, grid_clone)
                    if path_if_obstacle.loop then
                        obstacles_that_create_cycles[guard_position.row][guard_position.col - 1] = 1
                    else
                        obstacles_that_create_cycles[guard_position.row][guard_position.col - 1] = -1
                    end
                end
                if grid[guard_position.row][guard_position.col] ~= VISITED then
                    steps = steps + 1
                end
                grid[guard_position.row][guard_position.col] = VISITED
                guard_position.col = guard_position.col - 1
            end
        elseif guard_position.dir == RIGHT then
            if guard_position.col < #grid[1] and grid[guard_position.row][guard_position.col + 1] == WALL then
                guard_position.dir = DOWN
                grid[guard_position.row][guard_position.col] = DOWN
            else
                if visits[guard_position.row][guard_position.col].RIGHT then
                    loop = true
                    break
                end
                visits[guard_position.row][guard_position.col].RIGHT = true
                if guard_position.col < #grid[1] and check_for_loops and
                    obstacles_that_create_cycles[guard_position.row][guard_position.col + 1] == 0 and
                    (guard_position.row ~= original_guard_position.row or guard_position.col + 1 ~=
                        original_guard_position.col) then

                    local grid_clone = clone_grid(input_grid)
                    grid_clone[guard_position.row][guard_position.col + 1] = WALL
                    local path_if_obstacle = get_guard_path({
                        row = original_guard_position.row,
                        col = original_guard_position.col,
                        dir = original_guard_position.dir
                    }, grid_clone)
                    if path_if_obstacle.loop then
                        obstacles_that_create_cycles[guard_position.row][guard_position.col + 1] = 1
                    else
                        obstacles_that_create_cycles[guard_position.row][guard_position.col + 1] = -1
                    end
                end
                if grid[guard_position.row][guard_position.col] ~= VISITED then
                    steps = steps + 1
                end
                grid[guard_position.row][guard_position.col] = VISITED
                guard_position.col = guard_position.col + 1
            end
        end
    end

    local count_obstacles = 0
    for i = 1, #obstacles_that_create_cycles do
        for j = 1, #obstacles_that_create_cycles[1] do
            if obstacles_that_create_cycles[i][j] == 1 then
                count_obstacles = count_obstacles + 1
            end
        end
    end

    return {
        loop = loop,
        steps = steps,
        grid = grid,
        count_obstacles = count_obstacles
    }
end

local path = get_guard_path(original_guard_position, original_input, true)
print("Part 1: ", path.steps)
print("Part 2: ", path.count_obstacles)

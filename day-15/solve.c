#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define EXAMPLE 0
#define GRID_WIDTH (EXAMPLE ? 10 : 50)
#define GRID_HEIGHT (EXAMPLE ? 10 : 50)
#define COMMAND_BUFFER 20000

#define LEFT_COMMAND '<'
#define RIGHT_COMMAND '>'
#define UP_COMMAND '^'
#define DOWN_COMMAND 'v'

#define BOX_SYMBOL 'O'
#define WALL_SYMBOL '#'
#define ROBOT_SYMBOL '@'
#define EMPTY_SYMBOL '.'
#define LARGE_BOX_LEFT '['
#define LARGE_BOX_RIGHT ']'

void print_grid(char grid[GRID_HEIGHT][GRID_WIDTH])
{
    for (int i = 0; i < GRID_HEIGHT; i++)
    {
        for (int j = 0; j < GRID_WIDTH; j++)
        {
            printf("%c", grid[i][j]);
        }
        printf("\n");
    }
}

void print_large_grid(char grid[GRID_HEIGHT][2 * GRID_WIDTH])
{
    for (int i = 0; i < GRID_HEIGHT; i++)
    {
        for (int j = 0; j < 2 * GRID_WIDTH; j++)
        {
            printf("%c", grid[i][j]);
        }
        printf("\n");
    }
}

long compute_sum_of_coordinates(char grid[GRID_HEIGHT][GRID_WIDTH])
{
    long sum = 0;
    for (int i = 0; i < GRID_HEIGHT; i++)
    {
        for (int j = 0; j < GRID_WIDTH; j++)
        {
            if (grid[i][j] == BOX_SYMBOL)
            {
                sum += 100 * i + j;
            }
        }
    }
    return sum;
}

long compute_sum_of_coordinates_large(char grid[GRID_HEIGHT][2 * GRID_WIDTH])
{
    long sum = 0;
    for (int i = 0; i < GRID_HEIGHT; i++)
    {
        for (int j = 0; j < 2 * GRID_WIDTH; j++)
        {
            if (grid[i][j] == LARGE_BOX_LEFT)
            {
                sum += 100 * i + j;
            }
        }
    }
    return sum;
}

int main()
{
    FILE *fp = fopen((EXAMPLE ? "example" : "input"), "r");
    if (fp == NULL)
    {
        printf("Opening input file\n");
        return 1;
    }

    char grid[GRID_HEIGHT][GRID_WIDTH];
    char large_grid[GRID_HEIGHT][2 * GRID_WIDTH];
    char command_buffer[COMMAND_BUFFER + 1];
    int current_grid_row = 0;
    int section = 1;

    char buf[1024];
    int current_x = -1;
    int current_y = -1;
    int current_large_x = -1;
    int current_large_y = -1;
    while (fgets(buf, sizeof(buf), fp) != NULL)
    {
        if (strlen(buf) == 1)
        {
            section++;
            continue;
        }
        if (section == 1)
        {
            for (int i = 0; i < GRID_WIDTH; i++)
            {
                grid[current_grid_row][i] = buf[i];
                if (buf[i] == BOX_SYMBOL)
                {
                    large_grid[current_grid_row][2 * i] = LARGE_BOX_LEFT;
                    large_grid[current_grid_row][2 * i + 1] = LARGE_BOX_RIGHT;
                }
                else if (buf[i] == ROBOT_SYMBOL)
                {
                    current_x = i;
                    current_y = current_grid_row;
                    current_large_x = 2 * i;
                    current_large_y = current_grid_row;
                    large_grid[current_grid_row][2 * i] = ROBOT_SYMBOL;
                    large_grid[current_grid_row][2 * i + 1] = EMPTY_SYMBOL;
                }
                else
                {
                    large_grid[current_grid_row][2 * i] = buf[i];
                    large_grid[current_grid_row][2 * i + 1] = buf[i];
                }
            }
            current_grid_row++;
        }
        else
        {
            strcat(command_buffer, buf);
            command_buffer[strlen(command_buffer) - 1] = 0;
        }
    }
    fclose(fp);

    if (current_x == -1 || current_y == -1)
    {
        printf("Could not find the starting point\n");
        exit(1);
    }

    if (EXAMPLE)
    {
        print_grid(grid);
        printf("\n");
        printf("Starting at %d, %d\n", current_x, current_y);
    }

    for (int i = 0; i < strlen(command_buffer); i++)
    {
        char command = command_buffer[i];
        int next_x = command == LEFT_COMMAND ? current_x - 1 : (command == RIGHT_COMMAND ? current_x + 1 : current_x);
        int next_y = command == UP_COMMAND ? current_y - 1 : (command == DOWN_COMMAND ? current_y + 1 : current_y);
        if (grid[next_y][next_x] == WALL_SYMBOL)
        {
            continue;
        }
        if (grid[next_y][next_x] == EMPTY_SYMBOL)
        {
            grid[current_y][current_x] = EMPTY_SYMBOL;
            grid[next_y][next_x] = ROBOT_SYMBOL;
            current_x = next_x;
            current_y = next_y;
        }
        if (grid[next_y][next_x] == BOX_SYMBOL)
        {
            int further_x = next_x;
            int further_y = next_y;
            while (grid[further_y][further_x] == BOX_SYMBOL)
            {
                further_x = further_x + (next_x - current_x);
                further_y = further_y + (next_y - current_y);
            }
            if (grid[further_y][further_x] == WALL_SYMBOL)
            {
                continue;
            }
            if (grid[further_y][further_x] == EMPTY_SYMBOL)
            {
                grid[current_y][current_x] = EMPTY_SYMBOL;
                grid[next_y][next_x] = ROBOT_SYMBOL;
                grid[further_y][further_x] = BOX_SYMBOL;
                current_x = next_x;
                current_y = next_y;
            }
        }

        if (EXAMPLE)
        {
            print_grid(grid);
            printf("\n");
        }
    }

    printf("Part 1: %ld\n", compute_sum_of_coordinates(grid));

    if (EXAMPLE)
    {
        print_large_grid(large_grid);
        printf("Starting at %d, %d\n", current_large_x, current_large_y);
    }

    for (int i = 0; i < strlen(command_buffer); i++)
    {
        char command = command_buffer[i];
        int dx = command == LEFT_COMMAND ? -1 : (command == RIGHT_COMMAND ? 1 : 0);
        int dy = command == UP_COMMAND ? -1 : (command == DOWN_COMMAND ? 1 : 0);
        int next_x = current_large_x + dx;
        int next_y = current_large_y + dy;
        if (large_grid[next_y][next_x] == WALL_SYMBOL)
        {
            continue;
        }
        if (large_grid[next_y][next_x] == EMPTY_SYMBOL)
        {
            large_grid[current_large_y][current_large_x] = EMPTY_SYMBOL;
            large_grid[next_y][next_x] = ROBOT_SYMBOL;
            current_large_x = next_x;
            current_large_y = next_y;
        }
        if (large_grid[next_y][next_x] == LARGE_BOX_LEFT || large_grid[next_y][next_x] == LARGE_BOX_RIGHT)
        {
            if (next_x != current_large_x)
            {
                // Horizontal move
                int further_x = next_x + dx * 2;
                while (large_grid[next_y][further_x] == LARGE_BOX_LEFT || large_grid[next_y][further_x] == LARGE_BOX_RIGHT)
                {
                    further_x = further_x + dx * 2;
                }
                if (large_grid[next_y][further_x] == WALL_SYMBOL)
                {
                    continue;
                }
                if (large_grid[next_y][further_x] == EMPTY_SYMBOL)
                {
                    large_grid[current_large_y][current_large_x] = EMPTY_SYMBOL;
                    large_grid[next_y][next_x] = ROBOT_SYMBOL;
                    current_large_x = next_x;
                    current_large_y = next_y;
                    large_grid[next_y][further_x] = dx > 0 ? LARGE_BOX_RIGHT : LARGE_BOX_LEFT;
                    further_x -= dx;
                    while (next_x != further_x)
                    {
                        large_grid[next_y][further_x] = large_grid[next_y][further_x] == LARGE_BOX_LEFT ? LARGE_BOX_RIGHT : LARGE_BOX_LEFT;
                        further_x -= dx;
                    }
                }
            }
            else
            {
                // Vertical move
                char next_symbol = large_grid[next_y][next_x];
                int box_positions[GRID_HEIGHT * GRID_WIDTH][2];
                int box_positions_start_idx = 0;
                int box_positions_idx = 0;
                if (next_symbol == LARGE_BOX_LEFT)
                {
                    box_positions[box_positions_idx][0] = next_x;
                    box_positions[box_positions_idx][1] = next_y;
                    box_positions_idx++;
                }
                else if (next_symbol == LARGE_BOX_RIGHT)
                {
                    box_positions[box_positions_idx][0] = next_x - 1;
                    box_positions[box_positions_idx][1] = next_y;
                    box_positions_idx++;
                }
                int boxes_to_move[GRID_HEIGHT * GRID_WIDTH][2];
                int boxes_to_move_idx = 0;
                int can_move = 1;
                while (can_move == 1 && box_positions_start_idx < box_positions_idx)
                {
                    for (int i = box_positions_start_idx; i < box_positions_idx; i++)
                    {
                        int box_x_left = box_positions[i][0];
                        int box_x_right = box_positions[i][0] + 1;
                        int box_y = box_positions[i][1];
                        int next_box_y = box_y + dy;
                        if (large_grid[next_box_y][box_x_left] == WALL_SYMBOL || large_grid[next_box_y][box_x_right] == WALL_SYMBOL)
                        {
                            can_move = 0;
                            break;
                        }
                        if (large_grid[next_box_y][box_x_left] != EMPTY_SYMBOL)
                        {
                            box_positions[box_positions_idx][0] = large_grid[next_box_y][box_x_left] == LARGE_BOX_LEFT ? box_x_left : box_x_left - 1;
                            box_positions[box_positions_idx][1] = next_box_y;
                            box_positions_idx++;
                        }
                        if (large_grid[next_box_y][box_x_right] != EMPTY_SYMBOL && large_grid[next_box_y][box_x_right] != LARGE_BOX_RIGHT)
                        {
                            box_positions[box_positions_idx][0] = box_x_right;
                            box_positions[box_positions_idx][1] = next_box_y;
                            box_positions_idx++;
                        }
                    }
                    if (can_move == 1)
                    {
                        for (int i = box_positions_start_idx; i < box_positions_idx; i++)
                        {
                            boxes_to_move[boxes_to_move_idx][0] = box_positions[i][0];
                            boxes_to_move[boxes_to_move_idx][1] = box_positions[i][1];
                            boxes_to_move_idx++;
                        }
                        box_positions_start_idx = box_positions_idx;
                    }
                }
                if (can_move == 1)
                {
                    for (int i = 0; i < boxes_to_move_idx; i++)
                    {
                        large_grid[boxes_to_move[i][1]][boxes_to_move[i][0]] = EMPTY_SYMBOL;
                        large_grid[boxes_to_move[i][1]][boxes_to_move[i][0] + 1] = EMPTY_SYMBOL;
                    }
                    for (int i = 0; i < boxes_to_move_idx; i++)
                    {
                        large_grid[boxes_to_move[i][1] + dy][boxes_to_move[i][0]] = LARGE_BOX_LEFT;
                        large_grid[boxes_to_move[i][1] + dy][boxes_to_move[i][0] + 1] = LARGE_BOX_RIGHT;
                    }
                    large_grid[current_large_y][current_large_x] = EMPTY_SYMBOL;
                    large_grid[next_y][next_x] = ROBOT_SYMBOL;
                    current_large_x = next_x;
                    current_large_y = next_y;
                }
            }
        }

        if (EXAMPLE)
        {
            print_large_grid(large_grid);
            printf("\n");
        }
    }

    printf("Part 2: %ld\n", compute_sum_of_coordinates_large(large_grid));

    return 0;
}

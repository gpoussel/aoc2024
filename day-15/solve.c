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

long compute_sum_of_coordinates(char grid[GRID_HEIGHT][GRID_WIDTH])
{
    long sum = 0;
    for (int i = 0; i < GRID_HEIGHT; i++)
    {
        for (int j = 0; j < GRID_WIDTH; j++)
        {
            if (grid[i][j] == BOX_SYMBOL || grid[i][j] == LARGE_BOX_LEFT)
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
    char command_buffer[COMMAND_BUFFER + 1];
    int current_griw_row = 0;
    int section = 1;

    char buf[1024];
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
                grid[current_griw_row][i] = buf[i];
            }
            current_griw_row++;
        }
        else
        {
            strcat(command_buffer, buf);
            command_buffer[strlen(command_buffer) - 1] = 0;
        }
    }
    fclose(fp);

    int current_x = -1;
    int current_y = -1;
    for (int y = 0; y < GRID_HEIGHT; y++)
    {
        for (int x = 0; x < GRID_WIDTH; x++)
        {
            if (grid[y][x] == ROBOT_SYMBOL)
            {
                current_x = x;
                current_y = y;
            }
        }
    }
    if (current_x == -1 || current_y == -1)
    {
        printf("Could not find the starting point\n");
        exit(1);
    }

    print_grid(grid);
    printf("\n");
    printf("Starting at %d, %d\n", current_x, current_y);
    for (int i = 0; i < strlen(command_buffer); i++)
    {
        char command = command_buffer[i];
        int next_x = command == LEFT_COMMAND ? current_x - 1 : (command == RIGHT_COMMAND ? current_x + 1 : current_x);
        int next_y = command == UP_COMMAND ? current_y - 1 : (command == DOWN_COMMAND ? current_y + 1 : current_y);
        if (next_x < 0 || next_x >= GRID_WIDTH || next_y < 0 || next_y >= GRID_HEIGHT)
        {
            continue;
        }
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

    return 0;
}

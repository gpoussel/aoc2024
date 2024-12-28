#include <algorithm>
#include <climits>
#include <cmath>
#include <cstdlib>
#include <deque>
#include <iostream>
#include <fstream>
#include <queue>
#include <string>
#include <vector>
#include <sstream>

using namespace std;

#define MAP_SIZE 70
#define NUM_BYTES_TO_SIM 1024

struct coords
{
    int x;
    int y;
    int score;

    bool operator>(const coords &other) const
    {
        return score > other.score;
    }

    bool operator==(const coords &other) const
    {
        return x == other.x && y == other.y;
    }
};

vector<string> split(const string &s, char delim)
{
    vector<string> result;
    stringstream ss(s);
    string item;

    while (getline(ss, item, delim))
    {
        result.push_back(item);
    }

    return result;
}

vector<string> readFile(string path)
{
    ifstream file(path);
    vector<string> lines;
    string line;

    if (file.is_open())
    {
        while (getline(file, line))
        {
            lines.push_back(line);
        }
        file.close();
    }
    else
    {
        cerr << "Unable to open file" << endl;
    }

    return lines;
}

vector<coords> parseBytes(vector<string> input)
{
    vector<coords> fallingBytes;
    for (string byte : input)
    {
        vector<string> coord = split(byte, ',');
        fallingBytes.push_back({stoi(coord[0]), stoi(coord[1])});
    }
    return fallingBytes;
}

vector<string> createEmptyMemorySpace()
{
    vector<string> memorySpace;
    string row;
    for (int i = 0; i <= MAP_SIZE; i++)
    {
        row.push_back('.');
    }
    for (int j = 0; j <= MAP_SIZE; j++)
    {
        memorySpace.push_back(row);
    }
    return memorySpace;
}

void simulateFallingBytes(vector<string> *memorySpace, vector<coords> *fallingBytes, int numToSimulate)
{
    for (int i = 0; i < numToSimulate; i++)
    {
        coords byte = fallingBytes->at(i);
        memorySpace->at(byte.y).at(byte.x) = '#';
    }
}

bool isInMap(coords *next, vector<string> *map)
{
    return next->x >= 0 && next->x <= MAP_SIZE && next->y >= 0 && next->y <= MAP_SIZE;
}

bool isBlocked(coords *next, vector<string> *map)
{
    return map->at(next->y).at(next->x) == '#';
}

bool isVisited(coords next, vector<coords> *visited)
{
    for (int i = 0; i < visited->size(); i++)
    {
        if (next == visited->at(i))
        {
            return true;
        }
    }
    return false;
}
vector<coords> getCurrentOptions(coords currentCoord, vector<coords> visited, vector<string> *map)
{
    vector<coords> currentOptions;
    coords north = {currentCoord.x, currentCoord.y - 1, currentCoord.score + 1};
    coords east = {currentCoord.x + 1, currentCoord.y, currentCoord.score + 1};
    coords south = {currentCoord.x, currentCoord.y + 1, currentCoord.score + 1};
    coords west = {currentCoord.x - 1, currentCoord.y, currentCoord.score + 1};

    if (isInMap(&north, map) && !isBlocked(&north, map) && !isVisited(north, &visited))
    {
        currentOptions.push_back(north);
    }
    if (isInMap(&east, map) && !isBlocked(&east, map) && !isVisited(east, &visited))
    {
        currentOptions.push_back(east);
    }
    if (isInMap(&south, map) && !isBlocked(&south, map) && !isVisited(south, &visited))
    {
        currentOptions.push_back(south);
    }
    if (isInMap(&west, map) && !isBlocked(&west, map) && !isVisited(west, &visited))
    {
        currentOptions.push_back(west);
    }

    return currentOptions;
}

int findShortestPath(vector<string> *memorySpace, coords start, coords end)
{
    queue<coords> toExplore;
    vector<coords> visited;
    toExplore.push(start);

    while (!toExplore.empty())
    {
        coords current = toExplore.front();
        toExplore.pop();

        if (current.x == end.x && current.y == end.y)
        {
            return current.score;
        }

        visited.push_back(current);
        vector<coords> currentOptions = getCurrentOptions(current, visited, memorySpace);

        for (coords next : currentOptions)
        {
            bool alreadyQueued = false;
            queue<coords> tempQueue = toExplore;
            while (!tempQueue.empty())
            {
                if (tempQueue.front() == next)
                {
                    alreadyQueued = true;
                    break;
                }
                tempQueue.pop();
            }

            if (!alreadyQueued && find(visited.begin(), visited.end(), next) == visited.end())
            {
                toExplore.push(next);
            }
        }
    }
    return -1;
}

string binarySearchCutOff(vector<coords> fallingBytes)
{
    coords start = {0, 0};
    coords end = {MAP_SIZE, MAP_SIZE};
    vector<string> memorySpace = createEmptyMemorySpace();

    int low = 0;
    int high = fallingBytes.size() - 1;
    int mid;

    while (low <= high)
    {
        mid = low + (high - low) / 2;

        vector<string> tempMap = memorySpace;
        simulateFallingBytes(&tempMap, &fallingBytes, mid);
        int shortestPath = findShortestPath(&tempMap, start, end);

        if (shortestPath == -1)
        {
            high = mid - 1;
        }
        else
        {
            low = mid + 1;
        }
    }
    coords cutoff = fallingBytes[mid - 1];
    return "" + to_string(cutoff.x) + "," + to_string(cutoff.y);
}

int part1(vector<coords> fallingBytes)
{
    coords start = {0, 0};
    coords end = {MAP_SIZE, MAP_SIZE};
    vector<string> memorySpace = createEmptyMemorySpace();

    simulateFallingBytes(&memorySpace, &fallingBytes, NUM_BYTES_TO_SIM);
    int shortestPath = findShortestPath(&memorySpace, start, end);

    cout << "Part 1: " << shortestPath << endl;

    return 0;
}

int part2(vector<coords> fallingBytes)
{
    string cutoff = binarySearchCutOff(fallingBytes);

    cout << "Part 2: " << cutoff << endl;

    return 0;
}

int main()
{
    vector<string> input = readFile("input");
    vector<coords> fallingBytes = parseBytes(input);
    part1(fallingBytes);
    part2(fallingBytes);

    return 0;
}

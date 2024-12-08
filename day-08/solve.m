data = importdata('./input');

data = arrayfun(@(x) regexp(x, '.', 'match'), data);

N = size(data, 1);
grid = zeros(N, N);
for i = 1:N
    for j = 1:N
        grid(i, j) = data{i}{j};
    end
end

symbols = unique(grid(grid != '.'));

grid_part1 = grid(:,:);
grid_part2 = grid(:,:);
for s = 1:size(symbols, 1)
    symbol = symbols(s);
    [x y] = find(grid == symbol);

    for i = 1:size(x, 1)
        for j = i+1:size(x, 1)
            dx = x(j) - x(i);
            dy = y(j) - y(i);
            antinode1 = [x(i) - dx, y(i) - dy];
            antinode2 = [x(j) + dx, y(j) + dy];
            if antinode1(1) > 0 && antinode1(1) <= N && antinode1(2) > 0 && antinode1(2) <= N
                grid_part1(antinode1(1), antinode1(2)) = -1;
                while antinode1(1) > 0 && antinode1(1) <= N && antinode1(2) > 0 && antinode1(2) <= N
                    grid_part2(antinode1(1), antinode1(2)) = -1;
                    antinode1(1) = antinode1(1) - dx;
                    antinode1(2) = antinode1(2) - dy;
                end
            end
            if antinode2(1) > 0 && antinode2(1) <= N && antinode2(2) > 0 && antinode2(2) <= N
                grid_part1(antinode2(1), antinode2(2)) = -1;
                while antinode2(1) > 0 && antinode2(1) <= N && antinode2(2) > 0 && antinode2(2) <= N
                    grid_part2(antinode2(1), antinode2(2)) = -1;
                    antinode2(1) = antinode2(1) + dx;
                    antinode2(2) = antinode2(2) + dy;
                end
            end


        end
    end
end

disp(["Part 1: ", num2str(sum(grid_part1(:) == -1))]);
disp(["Part 2: ", num2str(sum(grid_part2(:) != '.'))]);

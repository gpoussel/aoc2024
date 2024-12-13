input_blocks = split(read("input", String), "\n\n")

for offset in [0, 10000000000000]
    response = 0
    for block in input_blocks
        parts = match(r"Button A: X\+(?<ax>\d+), Y\+(?<ay>\d+)\nButton B: X\+(?<bx>\d+), Y\+(?<by>\d+)\nPrize: X=(?<px>\d+), Y=(?<py>\d+)", block)
        a = (parse(Int, parts[:ax]), parse(Int, parts[:ay]))
        b = (parse(Int, parts[:bx]), parse(Int, parts[:by]))
        A = [a[1] b[1] ; a[2] b[2]]
        p = (parse(BigInt, parts[:px]) + offset, parse(BigInt, parts[:py]) + offset)
        target = [p[1] ; p[2]]
        result = A \ target
        nx = round(BigInt, result[1])
        ny = round(BigInt, result[2])

        if (nx * a[1] + ny * b[1] == p[1]) && (nx * a[2] + ny * b[2] == p[2])
            response += nx * 3 + ny
        end
    end

    println("Response for offset $offset: $response")
end

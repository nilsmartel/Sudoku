#!/usr/local/bin/julia

include("src/csp.jl")

# illegal value
n = 10

# taken from easysudoku
let easy = [1 7 9  6 n 3  5 n 4;
            5 8 6  4 n n  1 9 n;
            n 2 4  9 n 5  n n n;

            n n n  2 n n  9 n n;
            n n n  n 7 n  n 3 n;
            8 n n  3 n n  n n 6;

            n n n  1 3 2  n 4 n;
            n n 1  7 6 n  n n 8;
            7 n n  5 9 8  n 1 2;
           ]

    function get(x, y) :: Union{Int, Nothing}
        easy[(x-1)*9 + y]
    end

    assignmentset = Dict((x, y) => get(x, y) for x in 1:9, y in 1:9 if get(x, y) !== n)

    field = Sudoko(assignmentset)

    solution = solve_sudoko(field)
    # println(solution)
end

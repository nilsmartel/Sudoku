#!/usr/local/bin/julia

include("src/csp.jl")

"""
Testing out AC3
"""

function check(solution)
    if solution !== nothing
        println("(PASSED) solution found!")
        println(solution)
        return
    end
    println("(FAILED) no solution found!")
end

let csp = Csp([1, 2, 3], [1, 2], [
                                  Constraint([1, 2], ==)
                                  Constraint([1, 3], <)
                                 ])
    # expected solution
    expected = Dict(1 => 1, 2 => 1, 3 => 2)

    solution = backtrace(csp)

    check(solution)
end

let csp = begin
        constraints = [Constraint([a, b], !=) for a in 'a':'d', b in 'a':'b' if a != b]
        Csp('a':'d'|> collect, 1:4 |> collect, constraints, false)
          end

    solution = backtrace(csp)
    check(solution)
end

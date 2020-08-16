#!/usr/local/bin/julia

include("src/csp.jl")

"""
Testing out AC3
"""

let csp = Csp([1, 2, 3], [1, 2], [
                                  Constraint([1, 2], ==)
                                  Constraint([1, 3], <)
                                 ])
    # expected solution
    expected = Dict(1 => 1, 2 => 1, 3 => 2)

    solution = backtrace(csp)

    if solution !== nothing
        println("(PASSED) solution found!")
        println(solution)
    elseif
        println("(FAILED) no solution found!")
    end
end

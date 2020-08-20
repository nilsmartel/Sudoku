#!/usr/local/bin/julia

include("src/csp.jl")

"""
Testing out AC3
"""

function check(solution)
    if solution !== nothing
        println("(PASSED) solution found!")
        print("   ")
        println(solution)
        return
    end
    println("(FAILED) no solution found!")
end

begin
    Csp([1, 2, 3], [1, 2], [
                                  Constraint([1, 2], ==)
                                  Constraint([1, 3], <)
                                 ])
end |> backtrack |> check

begin
        constraints = [Constraint([a, b], !=) for a in 'a':'d', b in 'a':'b' if a != b]
        Csp('a':'d'|> collect, 1:4 |> collect, constraints, false)
end |> backtrack |> check


begin
    variables = 1:5 |> collect
    domain = ['a', 'b', 'c']
    constraints = [
                   Constraint([1, 2], ==),
                   Constraint([4, 5], ==),
                   Constraint([1, 3], !=),
                   Constraint([2, 4], !=),
                   Constraint([3, 5], !=),
                   Constraint([1, 3], >),
                  ]
    Csp(variables, domain, constraints)
end|> backtrack |> check

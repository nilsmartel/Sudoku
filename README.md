# Sudoku

Sudoku solver implemented in [Julia](https://julialang.org) using heavily optimized [Backtracking](https://en.wikipedia.org/wiki/Backtracking).

## How does it work?

The problem of filling a Sudoku grid needs to be formulated as a [Constraint Satisfaction Problem](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem) (short CSP).
That means we define
- A set of Variables X := {x1, x2, ..., xn}
- A domain of Values D := {d1, d2, ..., dn}
- A set of Constraints C

each variable needs to have a value assigned to in a constellation, that all constraints are respected.

## How does Backtracking work?

Backtracking simply assignes a Value for each Variable and checks if it works.
It may return early while assignind.

This is incredibly slow.

## How is this Version optimized

Most importantly [arc consistency](https://www.sciencedirect.com/topics/computer-science/arc-consistency) is enforced using the [ac-3 algorithm](https://www.youtube.com/watch?v=4cCS8rrYT14).
Furthermore heuristics are used, such as choosing the most restrained value first.

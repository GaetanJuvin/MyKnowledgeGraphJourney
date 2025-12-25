# Exercise 5: Inference Rules

Goal: derive new facts from existing ones using simple rules, then query the expanded graph.

What this exercise covers:
- a `infer!(max_iterations: 10)` loop that adds inferred edges
- Rule A: transitive `:IS_A` (A IS_A B, B IS_A C => A IS_A C)
- Rule B: `:PARENT_OF` implies `:RELATED_TO` (including symmetric edge)
- deduping with `edge_key` and tagging inferred edges in `props`

How to run:
```sh
ruby 005_infer.rb
```

Expected behavior:
- before inference, `"Engineer" IS_A ?x` returns only `"Professional"`
- after inference, it returns `"Professional"`, `"PersonType"`, `"Entity"`
- `:RELATED_TO` is inferred both directions from `:PARENT_OF`

Stretch ideas:
- add a rule registry so you can plug in new rules
- keep track of which rule fired for each inferred edge

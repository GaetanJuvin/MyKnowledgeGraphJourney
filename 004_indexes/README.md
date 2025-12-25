# Exercise 4: Indexes and Performance

Goal: speed up graph queries by indexing outgoing and incoming edges.

What this exercise covers:
- `@out[from][pred]` and `@in[to][pred]` indexes
- faster `neighbors` and `incoming` lookups
- `candidate_edges` to reduce the search space in `match`

How to run:
```sh
ruby 004_indexes.rb
```

What to notice:
- the same pattern matching API as Exercise 3
- dramatically fewer edges scanned when subject or object is bound

Stretch ideas:
- add a predicate-only index for queries like `["?s", :WORKS_AT, "?o"]`
- keep a count of edges scanned to compare with Exercise 3

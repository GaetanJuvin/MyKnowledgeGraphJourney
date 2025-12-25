# Exercise 2: Shortest Path with BFS

Goal: traverse the graph and return the shortest path between two nodes using Breadth-First Search (BFS).

What this exercise covers:
- `shortest_path(src, dst, predicates: nil)` using a queue and a visited set
- returning the path as an array: node, predicate, node, ...
- reusing `neighbors` to expand the frontier

How to run:
```sh
ruby 002_graph_traversal_with_BFS.rb
```

Example:
```
["Alice", :WORKS_AT, "Google", :PARTNERS_WITH, "OpenAI"]
```

Stretch ideas:
- allow filtering out specific predicates during traversal
- return the list of edges instead of alternating nodes and predicates

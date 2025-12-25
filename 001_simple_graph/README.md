# Exercise 1: Simple Graph

Goal: build the smallest possible knowledge graph with nodes, directed edges, and basic neighbor lookups.

What this exercise covers:
- a `KnowledgeGraph` that stores `@nodes` and `@edges`
- `add_node` and `add_edge` to build the graph
- `neighbors` and `incoming` to query outgoing/incoming edges

How to run:
```sh
ruby 001_simple_graph.rb
```

Expected behavior:
- prints the outgoing edges from "Alice"
- prints the incoming edges into "Google"

Stretch ideas:
- add a helper to list all nodes by `type`
- add a `remove_edge` method with a simple filter

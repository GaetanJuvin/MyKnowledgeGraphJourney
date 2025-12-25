# Knowledge Graph Journey (Ruby)

A tiny, progressive set of exercises that build a knowledge graph from scratch in plain Ruby.
Each step adds one core capability: representation, traversal, querying, indexing, inference, and time.

## How to run
Each exercise is a standalone Ruby file:
```sh
ruby 001_simple_graph/001_simple_graph.rb
ruby 002_graph_traversal_with_BFS/002_graph_traversal_with_BFS.rb
ruby 003_pattern_matching/003_pattern_matching.rb
ruby 004_indexes/004_indexes.rb
ruby 005_infer/005_infer.rb
ruby 006_validity_windows/006_validity_windows.rb
```

## Exercises
1) `001_simple_graph` - nodes, directed edges, basic neighbor lookups
2) `002_graph_traversal_with_BFS` - shortest path with BFS
3) `003_pattern_matching` - triple pattern queries with variables
4) `004_indexes` - outgoing/incoming indexes for faster matching
5) `005_infer` - rule-based inference (transitive IS_A, parent implies related)
6) `006_validity_windows` - time/versioning and retractions (truth maintenance)

Each folder has its own `README.md` with goal, usage, and stretch ideas.

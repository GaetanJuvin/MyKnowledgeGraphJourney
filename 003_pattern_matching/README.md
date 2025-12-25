# Exercise 3: Pattern Matching (Mini Cypher/SPARQL)

Goal: query the graph using triple patterns with variables and joins.

What this exercise covers:
- `variable?` to detect variables like `"?x"`
- `match(triples)` to find bindings that satisfy all triples
- joining multiple triples by carrying solution bindings forward

How to run:
```sh
ruby 003_pattern_matching.rb
```

Example queries:
```ruby
g.match([["?p", :WORKS_AT, "?c"], ["?c", :PARTNERS_WITH, "OpenAI"]])
g.match([["Alice", "?rel", "Google"]])
```

Stretch ideas:
- support optional patterns
- add basic predicate indexing to speed up matching

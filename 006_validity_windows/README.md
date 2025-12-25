# Exercise 6: Validity Windows and Retractions

Goal: add time/versioning to edges and support queries "as of" a point in time.

What this exercise should cover:
- storing `valid_from` / `valid_to` (or `created_at` / `retracted_at`) in edge props
- querying only edges valid at a given timestamp
- retracting facts without losing history
- optional: retract inferred edges when a supporting fact is removed

How to run:
```sh
ruby 006_validity_windows.rb
```

Suggested API:
```ruby
g.add_edge("Alice", :WORKS_AT, "Google", valid_from: 2022, valid_to: 2024)
g.match([["Alice", :WORKS_AT, "?c"]], at: 2023)
g.retract_edge("Alice", :WORKS_AT, "Google", at: 2024)
```

Stretch ideas:
- add "bitemporal" support (valid time vs transaction time)
- explain results with the history of facts

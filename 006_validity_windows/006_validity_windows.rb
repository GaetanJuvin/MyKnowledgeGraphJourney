require "set"

class KnowledgeGraph
    attr_accessor :nodes, :edges

    def initialize
        @nodes = {}
        @edges = []
        @out = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
        @in  = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }
    end

    def add_node(id, **props)
        @nodes[id] ||= {}
        @nodes[id].merge!(props)
    end

    def add_edge(from, pred, to, **props)
        add_node(from)
        add_node(to)
        edge = { from: from, pred: pred, to: to, props: props}

        @edges << edge
        @out[from][pred] << edge
        @in[to][pred]    << edge

        edge
    end

    def neighbors(from, predicate: nil, as_of: nil)
        edges =
            if predicate
            (@out[from] && @out[from][predicate]) ? @out[from][predicate] : []
            else
            (@out[from] ? @out[from].values.flatten : [])
            end

        as_of ? edges.select { |e| edge_valid?(e, as_of) } : edges.dup
    end

    def incoming(to, predicate: nil, as_of: nil)
        edges =
            if predicate
            (@in[to] && @in[to][predicate]) ? @in[to][predicate] : []
            else
            (@in[to] ? @in[to].values.flatten : [])
            end

        as_of ? edges.select { |e| edge_valid?(e, as_of) } : edges.dup
    end

    def shortest_path(src, dst, predicates: nil)
        return [src] if src == dst

        visited = {}
        queue = [[src]]
        visited[src] = true
        while queue.any?
            path = queue.shift
            current = path.last

            neighbors(current, predicate: nil).each do |edge|
                next if predicates and predicates.include?(edge[:prep])

                nxt = edge[:to]
                next if visited[nxt]

                new_path = path + [edge[:pred], nxt]
                return new_path if nxt == dst

                visited[nxt] = true
                queue << new_path
            end
        end
        nil
    end

    def variable?(x)
        x.is_a?(String) and x.start_with?("?")
    end

    def resolve(term, binding)
        variable?(term) ? binding[term] : term
    end

     def candidate_edges(subject, predicate, object, bindings, as_of: nil)
        bound_subject   = resolve_term(subject, bindings)
        bound_predicate = resolve_term(predicate, bindings)
        bound_object    = resolve_term(object, bindings)

        candidates =
        if bound_subject
            if bound_predicate
            @outgoing.dig(bound_subject, bound_predicate) || []
            else
            (@outgoing[bound_subject] || {}).values.flatten
            end
        elsif bound_object
            if bound_predicate
            @incoming.dig(bound_object, bound_predicate) || []
            else
            (@incoming[bound_object] || {}).values.flatten
            end
        else
            @edges
        end

        as_of ? candidates.select { |e| edge_valid_at?(e, as_of) } : candidates
    end

    def match(triples, as_of: nil)
        solutions = [{}]

        triples.each do |(subject, predicate, object)|
            new_solutions = []

            solutions.each do |binding|
                candidate_edges(subject, predicate, object, binding, as_of: as_of).each do |e|
                    subject_value = resolve(subject, binding) || e[:from]
                    predicate_value = resolve(predicate, binding) || e[:pred]
                    object_value = resolve(object, binding) || e[:to]

                    next unless e[:from] == subject_value
                    next unless e[:pred] == predicate_value
                    next unless e[:to]   == object_value

                    new_binding = binding.dup

                    if variable?(subject)
                        next if new_binding[subject] && new_binding[subject] != e[:from]
                        new_binding[subject] = e[:from]
                    end

                    if variable?(predicate)
                        next if new_binding[predicate] && new_binding[predicate] != e[:pred]
                        new_binding[predicate] = e[:pred]
                    end

                    if variable?(object)
                        next if new_binding[object] && new_binding[object] != e[:to]
                        new_binding[object] = e[:to]
                    end

                    new_solutions << new_binding
                end
            end

            solutions = new_solutions
        end

        solutions
    end

    def edge_key(from, pred, to)
        "#{from}|#{pred}|#{to}"
    end

    def infer!(max_iterations: 10)
        known = Set.new
        @edges.each { |e| known << edge_key(e[:from], e[:pred], e[:to]) }

        index = 0
        max_iterations.times do
            newly_added = 0

            # For each A IS_A B and B IS_A C, add A IS_A C
            @out.each do |a, preds|
                next unless preds.key?(:IS_A)

                preds[:IS_A].each do |e1|
                    b = e1[:to]
                    next unless @out.key?(b) and @out[b].key?(:IS_A)

                    @out[b][:IS_A].each do |e2|
                        c = e2[:to]
                        next if c == a

                        k = edge_key(a, :IS_A, c)
                        next if known.include?(k)

                        add_edge(a, :IS_A, c, inferred: true, rule: "transitive_IS_A")
                        known << k
                        newly_added += 1
                    end
                end
            end

            # For each x PARENT_OF y, add x RELATED_TO y and y RELATED_TO x
            @edges.select { |e| e[:pred] == :PARENT_OF }.each do |e|
                x = e[:from]
                y = e[:to]

                k1 = edge_key(x, :RELATED_TO, y)
                unless known.include?(k1)
                    add_edge(x, :RELATED_TO, y, inferred: true, rule: "parent_implies_related")
                    known << k1
                    newly_added += 1
                end

                k2 = edge_key(y, :RELATED_TO, x)
                unless known.include?(k2)
                    add_edge(y, :RELATED_TO, x, inferred: true, rule: "parent_implies_related_symmetric")
                    known << k2
                    newly_added += 1
                end
                break if newly_added == 0
            end
        end
    end

    def edge_valid?(edge, as_of)
        return unless as_of

        vf = edge[:props].fetch(:valid_from, -Float::INFINITY)
        vt = edge[:props].fetch(:valid_to, Float::INFINITY)

        ((vf <= as_of) and (as_of < vt))
    end

    def retract_edge(from, pred, to, at:)
        affected = 0

        (@out.dig(from, pred) || []).each do |e|
            next unless e[:to] == to

            vf = e[:props].fetch(:valid_from, -Float::INFINITY)
            vt = e[:props].fetch(:valid_to,   Float::INFINITY)

            next unless vf < at && at < vt

            e[:props][:valid_to] = at
            affected += 1
        end

        affected
    end
end

g = KnowledgeGraph.new
g.add_node("Alice", type: "Person")
g.add_node("Bob", type: "Person")
g.add_node("Google", type: "Company")
g.add_node("OpenAI", type: "Company")
g.add_node("Engineer", type: "Role")

g.add_edge("Alice", :WORKS_AT, "Google", since: 2022)
g.add_edge("Bob", :WORKS_AT, "OpenAI", since: 2023)
g.add_edge("Alice", :HAS_ROLE, "Engineer")
g.add_edge("Engineer", :IS_A, "Professional")
g.add_edge("Professional", :IS_A, "PersonType")
g.add_edge("Google", :PARTNERS_WITH, "OpenAI")

# p "001"

# p g.neighbors("Alice")
# # => Alice -[:WORKS_AT]-> Google
# # => Alice -[:HAS_ROLE]-> Engineer

# p g.incoming("Google")
# # => Alice -[:WORKS_AT]-> Google

# p g.incoming("Google", predicate: :WORKS_AT)
# # => same result

# p "002"
# p g.shortest_path("Alice", "OpenAI")
# # => ["Alice", :WORKS_AT, "Google", :PARTNERS_WITH, "OpenAI"]
# p g.shortest_path("Bob", "Google")
# # => nil

# p "003"
# g.add_edge("Alice", :FOUNDED, "Google")
# p g.match([["?p", :WORKS_AT, "?c"], ["?c", :PARTNERS_WITH, "OpenAI"]])

# p g.match([["Alice", "?rel", "Google"]])

# p "005"
# g = KnowledgeGraph.new

# g.add_edge("Engineer", :IS_A, "Professional")
# g.add_edge("Professional", :IS_A, "PersonType")
# g.add_edge("PersonType", :IS_A, "Entity")
# g.add_edge("Alice", :PARENT_OF, "Bob")

# puts "Before inference:"
# p g.match([["Engineer", :IS_A, "?x"]]) # should only have Professional

# g.infer!

# puts "After inference:"
# p g.match([["Engineer", :IS_A, "?x"]])
# # Expect Professional, PersonType, Entity

# p g.match([["Alice", :RELATED_TO, "?x"]])
# # # Expect Bob

# p g.match([["Bob", :RELATED_TO, "?x"]])
# # Expect Alice

p "006"
g = KnowledgeGraph.new

g.add_edge("Alice", :WORKS_AT, "Google", valid_from: 2022)
p g.neighbors("Alice", predicate: :WORKS_AT, as_of: 2024).map { |e| [e[:from], e[:pred], e[:to], e[:props]] }
# => should include Google

g.retract_edge("Alice", :WORKS_AT, "Google", at: 2025)

p g.neighbors("Alice", predicate: :WORKS_AT, as_of: 2024).map { |e| [e[:from], e[:pred], e[:to], e[:props]] }
# => still includes (valid)

p g.neighbors("Alice", predicate: :WORKS_AT, as_of: 2025).map { |e| [e[:from], e[:pred], e[:to], e[:props]] }
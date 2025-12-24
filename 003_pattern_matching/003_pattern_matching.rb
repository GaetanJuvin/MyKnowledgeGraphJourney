class KnowledgeGraph
    attr_accessor :nodes, :edges

    def initialize
        @nodes = {}
        @edges = []
    end

    def add_node(id, **props)
        @nodes[id] ||= {}
        @nodes[id].merge!(props)
    end

    def add_edge(from, pred, to, **props)
        add_node(from)
        add_node(to)
        @edges << { from: from, pred: pred, to: to, props: props}
    end

    def neighbors(from, predicate: nil)
        out = @edges.select { |e| e[:from] == from }
        out = out.select { |e| e[:pred] == predicate } if predicate
        out
    end

    def incoming(to, predicate: nil)
        out = @edges.select { |e| e[:to] == to }
        out = out.select { |e| e[:pred] == predicate } if predicate
        out
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

    def match(triples)
        solutions = [{}]

        triples.each do |(subject, predicate, object)|
            new_solutions = []

            solutions.each do |solution|
                @edges.each do |e|
                    subject_value = variable?(subject) ? solution[subject] || e[:from] : subject
                    predicate_value = variable?(predicate) ? solution[predicate] || e[:pred] : predicate
                    object_value = variable?(object) ? solution[object] || e[:to]   : object

                    next unless e[:from] == subject_value
                    next unless e[:pred] == predicate_value
                    next unless e[:to]   == object_value

                    new_binding = solution.dup

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

p "003"
g.add_edge("Alice", :FOUNDED, "Google")
p g.match([["?p", :WORKS_AT, "?c"], ["?c", :PARTNERS_WITH, "OpenAI"]])

p g.match([["Alice", "?rel", "Google"]])

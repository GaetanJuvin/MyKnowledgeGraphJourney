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

p g.neighbors("Alice")
# => Alice -[:WORKS_AT]-> Google
# => Alice -[:HAS_ROLE]-> Engineer

p g.incoming("Google")
# => Alice -[:WORKS_AT]-> Google

p g.incoming("Google", predicate: :WORKS_AT)
# => same result

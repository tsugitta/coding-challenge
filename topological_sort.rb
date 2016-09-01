class TopologicalSort
  def exec(graph)
    topological_sort(graph)
  end

  def count(graph)
    @hash_table = {}
    p count_topological_sort(graph)
  end

  private

  def topological_sort(graph, sorted_node_ids = [])
    if graph.is_empty?
      p sorted_node_ids
      return
    end

    graph.nodes_that_have_no_from_nodes.each do |node|
      _sorted_node_ids, _graph = sorted_node_ids.dup, graph.dup

      _sorted_node_ids << node.id
      _graph.remove_node_and_its_direction(node.id)
      topological_sort(_graph, _sorted_node_ids)
    end
  end

  def count_topological_sort(graph)
    if graph.is_empty?
      return 1
    end

    @hash_table[graph.nodes_binary_value] ||= graph.nodes_that_have_no_from_nodes.map { |node|
      _graph = graph.dup

      _graph.remove_node_and_its_direction(node.id)
      count_topological_sort(_graph)
    }.inject(:+)
  end
end

class TopologicalSort2
  def count(graph)
    @graph = graph.freeze
    @hash_table = {}
    p count_topological_sort
  end

  private

  def count_topological_sort(node_binary = nil)
    node_binary = '1' * @graph.nodes.count unless node_binary

    unless node_binary.include?('1')
      return 1
    end

    @hash_table[node_binary] ||= begin
      node_binaries_removing_node_not_having_from_nodes(node_binary).map { |next_binary|
        count_topological_sort(next_binary)
      }.inject(:+)
    end
  end

  def node_binaries_removing_node_not_having_from_nodes(node_binary)
    _graph = @graph.dup

    removed_node_ids(node_binary).each do |node_id|
      _graph.remove_node_and_its_direction(node_id)
    end

    _graph.nodes_that_have_no_from_nodes.map do |node|
      _node_binary = node_binary.dup
      _node_binary[_node_binary.size - node.id] = '0'
      _node_binary
    end
  end

  def removed_node_ids(node_binary)
    ids = []

    node_binary.each_char.with_index do |char, i|
      ids << (node_binary.size - i) if char == '0'
    end

    ids
  end
end

class Graph
  attr_reader :nodes

  def initialize(nodes)
    @nodes = nodes
  end

  def dup
    _nodes = @nodes.map(&:dup)
    Graph.new(_nodes)
  end

  def find(node_id)
    @nodes.find { |n| n.id == node_id }
  end

  def nodes_that_have_no_from_nodes
    @nodes.select { |n| n.from_node_ids.empty? }
  end

  def nodes_that_have_no_to_nodes
    @nodes.select { |n| n.to_node_ids.empty? }
  end

  def remove_node_and_its_direction(node_id)
    node = find(node_id)
    raise 'cannot remove non-existent node' if node == nil

    node.from_node_ids.each do |from_node_id|
      find(from_node_id).to_node_ids.delete(node.id)
    end

    node.to_node_ids.each do |to_node_id|
      find(to_node_id).from_node_ids.delete(node.id)
    end

    @nodes.delete_if { |n| n.id == node_id }
  end

  def is_empty?
    @nodes.empty?
  end

  # can be used only if id is sequencial number and its beginning is 1
  def nodes_binary_value
    binary = '0' * @nodes.map(&:id).max

    @nodes.each do |node|
      binary[@nodes.count - node.id] = '1'
    end

    binary
  end
end

class Node
  attr_reader :id, :from_node_ids, :to_node_ids

  def initialize(id, from_node_ids = [], to_node_ids = [])
    @id = id
    @from_node_ids = from_node_ids
    @to_node_ids = to_node_ids
  end

  def dup
    Node.new(@id, @from_node_ids.dup, @to_node_ids.dup)
  end
end

class GraphCreator
  # text_input like below:
  # 5 5 # the number of nodes, the number of input for direction
  # 1 2 # the node 1 is directed toward the node 2
  # 2 3
  # 3 5
  # 1 4
  # 4 5
  def exec(input_text)
    inputs = input_array_from_string(input_text)
    nodes_count, direction_count = inputs.first
    direction_inputs = inputs[1..-1]

    unless direction_count == direction_inputs.count
      raise "Invalid input. direction_count: #{direction_count} but there are #{@inputs.count - 1} inputs."
    end

    nodes = nodes_with_count(nodes_count)
    graph = Graph.new(nodes)
    graph_added_direction_information(graph, direction_inputs)
  end

  private

  def input_array_from_string(input_text)
    input_text.split("\n").map do |one_line_input|
      one_line_input.split(' ').map(&:to_i)
    end
  end

  def nodes_with_count(count)
    Array.new(count) do |i|
      id = i + 1
      Node.new(id)
    end
  end

  def graph_added_direction_information(graph, direction_inputs)
    direction_inputs.each do |input|
      from_node_id, to_node_id = input
      from_node, to_node = graph.find(from_node_id), graph.find(to_node_id)

      if [from_node, to_node].include?(nil)
        raise "Invalid input. the direction: '#{from_node_id} -> #{to_node_id}' includes non-existent node."
      end

      if from_node.to_node_ids.include?(to_node_id) || to_node.from_node_ids.include?(from_node_id)
        raise "Invalid input. direction from #{from_node_id} to #{to_node_id} is declared more than once."
      end

      from_node.to_node_ids << to_node_id
      to_node.from_node_ids << from_node_id
    end

    graph
  end
end

input_text = <<EOS
5 5
1 2
2 3
3 5
1 4
4 5
EOS

graph = GraphCreator.new.exec(input_text)
TopologicalSort2.new.count(graph)

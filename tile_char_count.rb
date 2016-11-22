# Question:
# A tile composed of W * H small grid is given.
# Each grid contains a lower-case letter.
# On a 2-dim plane, this tile is laid repeatedly without a break,
# without any rotation and with tile's top-left corner on origin.
# Answer the number of a given letter in the given domain.

# the input consists of tile's information(its size, containing letters) and
# Q queries. a query includes the domain's left, right, bottom, top edge,
# and the letter.

# input is like:
# H W
# C_{1, 1} C_{1, 2} ... C_{1, W}
# ...
# C_{H, 1} C_{H, 2} ... C_{H, W}
# Q
# l_1 r_1 b_1 t_1 c_1
# ...
# l_Q r_Q b_Q t_Q c_Q

# Approach:
# each grid in the tile, calculate how many times the tile can be regarded
# as stepped. and call it as 'step_count_matrix'.
# in step_count_matrix, by summing up the grid containing the requested letter,
# the answer is obtained.
#
# when the tile is like:
# ab
# ca
#
# and the domain is { l: 0, r: 5, b: 0, t: 3 } as:
#
# cacac
# ababa
# cacac
#
# then, step_count_matrix is
# [[3, 2],
#  [6, 4]]
# which presents top-left a is stepped 3 times, b is stepped 2 times,
# c is stepped 6 times, bottom-right a is stepped 4 times.

# after calculating step_count_matrix, just pick up the step_count whose grid
# contains the requested letter. to do this, get dot-product with `including_char_matrix`.
# including_char_matrix consists of 1 and 0. the grids containing the letter are 1,
# the others are 0.
# suppose the letter is 'a'. then, including_char_matrix is like:
# [[1, 0],
#  [0, 1]]
# and dot-product of this with step_count_matrix is
# [[3, 2], * [[1, 0],  = 3 * 1 + 4 * 1 = 7
#  [6, 4]]    [0, 1]]
# the number of 'a' is gotten in this way.

input_1 = <<-EOS
2 2
ab
cd
3
0 2 0 2 a
0 3 0 3 a
1 2 1 2 a
EOS
# output should be:
# 1
# 2
# 0

input_2 = <<-EOS
4 4
abba
bbaa
aabb
baab
3
-2 2 -2 2 a
-3 5 -1 4 b
0 5 0 2 a
EOS
# output should be:
# 8
# 20
# 5

input_3 = <<-EOS
4 9
abcabacbb
abcabcaca
bcbcababc
bacbcabcb
3
-1000000000 1000000000 -1000000000 1000000000 a
-1000000000 1000000000 -1000000000 1000000000 b
-1000000000 1000000000 -1000000000 1000000000 c
EOS
# output should be:
# 1222222222500000000
# 1555555556000000000
# 1222222221500000000

inputs = [input_1, input_2, input_3]

module MathHelper
  def cross_product(v_a, v_b) # assume v_a is a column vector, v_b is a row vector
    width = v_b.size
    height = v_a.size

    (0..height-1).map do |h|
      (0..width-1).map do |w|
        v_a[h] * v_b[w]
      end
    end
  end

  def dot_product(m_a, m_b)
    res = 0

    m_a.each_with_index do |a_row, r_i|
      a_row.each_with_index do |_, c_i|
        res += m_a[r_i][c_i] * m_b[r_i][c_i]
      end
    end

    res
  end

  module_function :cross_product, :dot_product
end

class Tile
  attr_reader :chars, :width, :height
  alias_method :w, :width
  alias_method :h, :height
  # chars is like:
  # [['a', 'b'],
  #   'c', 'd']]
  #
  # @chars is like:
  # [['c', 'd'],
  #  ['a', 'b']]
  # to access lower row with smaller index along with y axis
  def initialize(chars)
    @chars = chars.reverse
    @width = chars[0].size
    @height = chars.size
    @including_char_matrix = {}
  end

  # if char is 'c', referring to @chars:
  # [[1, 0],
  #  [0, 0]]
  def including_char_matrix(char)
    @including_char_matrix[char] ||= begin
      @chars.map do |row|
        row.map do |c|
          char == c ? 1 : 0
        end
      end
    end
  end
end

class Query
  attr_reader :l, :r, :b, :t, :c

  def initialize(params)
    params.each { |k, v| instance_variable_set("@#{k}", v) }
  end
end

class Solver
  attr_reader :property
  alias_method :p, :property

  def initialize(input)
    @property = Solver::InputConverter.new(input).convert_to_problem_property
  end

  def solve
    p.queries.each { |q| solve_query(q) }
  end

  private

  def solve_query(q)
    h_step_counts = step_counts_array(p.tile.w, q.l, q.r - 1)
    v_step_counts = step_counts_array(p.tile.h, q.b, q.t - 1)
    step_count_matrix = MathHelper.cross_product(v_step_counts, h_step_counts)

    char_counts = MathHelper.dot_product \
      p.tile.including_char_matrix(q.c), step_count_matrix
    puts char_counts
  end

  # ex)
  # tile_length: 4, small_edge: 1, big_edge: 2
  # => [0, 1, 1, 0]
  # tile_length: 4, small_edge: 3, big_edge: 5
  # => [1, 1, 0, 1]
  # tile_length: 4, small_edge: 7, big_edge: 16
  # => [3, 2, 2, 3]
  def step_counts_array(tile_length, small_edge, big_edge)
    begin_index = small_edge % tile_length
    repeat_count, step_from_begin = (big_edge - small_edge).divmod(tile_length)

    res = Array.new(tile_length, repeat_count)
    (0..step_from_begin).each do |s|
      res[(begin_index + s) % tile_length] += 1
    end

    res
  end
end

class Solver::ProblemProperty
  attr_reader :tile, :queries

  def initialize(params)
    params.each { |k, v| instance_variable_set("@#{k}", v) }
  end
end

class Solver::InputConverter
  def initialize(input)
    @input = input
  end

  def convert_to_problem_property
    input_chars = @input.split("\n").map { |row| row.split("\s") }

    height, width = input_chars.shift.map(&:to_i)
    tile_inputs = input_chars.shift(height)

    query_counts = input_chars.shift.first.to_i
    query_inputs = input_chars.shift(query_counts)

    Solver::ProblemProperty.new \
      tile: Tile.new(tile_params(tile_inputs)),
      queries: query_params(query_inputs).map { |p| Query.new(p) }
  end

  private

  def tile_params(inputs)
    inputs.map do |row|
      row.map do |chars|
        chars.split('')
      end.flatten
    end
  end

  def query_params(inputs)
    inputs.map do |i|
      { l: i[0].to_i, r: i[1].to_i, b: i[2].to_i, t: i[3].to_i, c: i[4] }
    end
  end
end

require 'benchmark'

inputs.each.with_index(1) do |input, i|
  puts "input: #{i}"
  result = Benchmark.realtime do
    Solver.new(input).solve
  end
  puts "finished in #{result}s\n\n"
end

# in my environment, the result is:

# input: 1
# 1
# 2
# 0
# finished in 0.00013658399984706193s
#
# input: 2
# 8
# 20
# 5
# finished in 0.00020197199773974717s
#
# input: 3
# 1222222222500000000
# 1555555556000000000
# 1222222221500000000
# finished in 0.0009809010007302277s

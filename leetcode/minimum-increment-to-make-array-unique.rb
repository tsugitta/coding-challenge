# @param {Integer[]} a
# @return {Integer}
def min_increment_for_unique(a)
  map = Hash.new(0)

  max = 0

  a.each do |num|
    map[num] += 1
    max = num if num > max
  end

  res = 0
  i = 0

  while i <= max
    if map[i] > 1
      res += map[i] - 1
      map[i+1] += map[i] - 1

      if i == max
        max += 1
      end
    end

    i += 1
  end

  res
end

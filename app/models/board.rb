class Board < ActiveRecord::Base
  class LayoutError < StandardError ; end

  belongs_to :server

  def representation
    JSON.parse json_representation
  rescue
    {}
  end

  def representation=(rep)
    self.json_representation = rep.to_json
  end

  def get_cell(x,y)
    representation["#{x}_#{y}"]
  end

  def cell_exists?(x,y)
    return false if x < 0
    return false if x > width - 1
    return false if y < 0 
    return false if y > height - 1
    return true
  end

  def fill_cell!(x, y, item)
    raise LayoutError, "Out of bounds piece: Cell exists #{[x,y].inspect} #{cell_exists?(x,y).inspect} for board [#{width}, #{height}]" unless cell_exists?(x,y)
    raise LayoutError, "Overlap: Two items intersect at [#{x},#{y}]" if get_cell(x,y)
    fill_cell x, y, item
  end

  def fill_cell(x,y, item)
    rep = representation
    rep["#{x}_#{y}"] = item
    self.representation = rep
  end

  def count_cells_containing(item)
    representation.values.select {|v| v == item}.count
  end

  def unharmed_critters
    self.representation.values.select { |item| item !=~ /hit/ && item !=~ /miss/}
  end

end


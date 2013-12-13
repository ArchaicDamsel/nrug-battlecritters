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

  def fill_cell!(x, y, item)
    raise LayoutError, "Overlap: Two items intersect at [#{x},#{y}]" if get_cell(x,y)
    fill_cell x, y, item
  end

  def fill_cell(x,y, item)
    rep = representation
    rep["#{x}_#{y}"] = item
    self.representation = rep
  end

  def unharmed_critters
    self.representation.values.select { |item| item !=~ /hit/ && item !=~ /miss/}
  end

  def cell_exists?(x,y)
  end

end

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

  def getCell(x,y)
    representation["#{x}_#{y}"]
  end

  def fillCell!(x, y, item)
    raise LayoutError, "Overlap: Two items intersect at [#{x},#{y}]" if getCell(x,y)
    fillCell x, y, item
  end

  def fillCell(x,y, item)
    rep = representation
    rep["#{x}_#{y}"] = item
    self.representation = rep
  end
end

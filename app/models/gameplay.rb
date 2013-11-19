class Gameplay < ActiveRecord::Base
  def self.current
    self.order('created_at DESC').first
  end
end

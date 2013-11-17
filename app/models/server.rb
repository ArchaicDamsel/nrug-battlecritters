class Server < ActiveRecord::Base
  def self.request_an_animal
    self.find_by_current_role 'server'
  end
end

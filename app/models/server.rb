class Server < ActiveRecord::Base
  class << self
    # DO NOT USE - try Player.fox instead!
    def fox
      find_by_current_role :fox
    end

    # DO NOT USE - try Badger.fox instead!
    def badger
      find_by_current_role :badger
    end

    def main
      find_by_current_role :badger
    end

    def make_main(url)
      Server.find_or_create_by(:hostname => url).update_attribute :current_role, 'server'
    end

    def request_an_animal
      self.find_by_current_role 'server'
    end

    def make_badger

    end
  end

  has_one :board
end

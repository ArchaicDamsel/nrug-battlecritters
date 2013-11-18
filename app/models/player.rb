# This is a semantic shim.
# Players are really just servers. Shhhh, don't tell anyone...
class Player
  class << self
    def fox
      Server.fox
    end

    def badger
      Server.badger
    end

    def create_fox(url)
      Server.find_or_create_by(:hostname => url).update_attribute :current_role, 'fox'
    end

    def create_badger(url)
      Server.find_or_create_by(:hostname => url).update_attribute :current_role, 'badger'
    end
  end
end
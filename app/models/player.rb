# This is a semantic shim.
# Players are really just servers. Shhhh, don't tell anyone...
class Player
  class << self
    def find_by_animal(animal)
      Server.find_by_current_role animal
    end

    def fox
      Server.fox
    end

    def badger
      Server.badger
    end

    def create_fox(url)
      animal = Server.find_or_create_by(:hostname => url)
      animal.update_attribute :current_role, 'fox'
      animal
    end

    def create_badger(url)
      animal = Server.find_or_create_by(:hostname => url)
      animal.update_attribute :current_role, 'badger'
      animal
    end
  end
end
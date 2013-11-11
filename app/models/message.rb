class Message < ActiveRecord::Base
  belongs_to :server
  belongs_to :in_response_to

  class << self
    def transmit

    end
  end
end

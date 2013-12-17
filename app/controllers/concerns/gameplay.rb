module Concerns
  module Gameplay

    def index_url
      gameplays_index_path :uuid => @uuid
    end

    def new_url
      gameplays_new_path :uuid => @uuid
    end

    def edit_url
      gameplays_edit_path :uuid => @uuid
    end

    def finish_url
      gameplays_finish_path :uuid => @uuid
    end

    def check_for_winner(response)
      if response['winner']
        winner = Player.find_by_animal response['winner']
        winner.update_attribute :winner, true
        winner.opponent.update_attribute :loser, true
      end
    end

    def connect_to_api(path)
      @api = SimpleHttp.new(Server.main.hostname + path + "?uuid=#{@uuid}")
      @api.register_response_handler Net::HTTPResponse do |request, response, other|
        response.body
      end
    end

    def get_from_api(path) 
      connect_to_api path
      JSON.parse @api.get
    end

    def put_to_api(path, data)
      uri = URI.parse('http://' + Server.main.hostname + path + "?uuid=#{@uuid}")
      req = Net::HTTP::Put.new(uri)
      req.body = build_nested_query(data)
      response = Net::HTTP.start(uri.hostname, uri.port)  do |http|
        http.request req
      end
      JSON.parse response.body
    end

    def post_to_api(path, data)
      uri = URI.parse('http://' + Server.main.hostname + path + "?uuid=#{@uuid}")
      req = Net::HTTP::Post.new(uri)
      req.body = build_nested_query(data)
      response = Net::HTTP.start(uri.hostname, uri.port)  do |http|
        http.request req
      end
      JSON.parse response.body
    end

    # Stolen from Rack::Utils, but modified
    # https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L150
    def build_nested_query(value, prefix = nil)
      case value
      when Array
        value.map { |v|
          build_nested_query(v, "#{prefix}[]")
        }.join("&")
      when Hash
        value.map { |k, v|
          build_nested_query(v, prefix ? "#{prefix}[#{Rack::Utils.escape(k)}]" : Rack::Utils.escape(k))
        }.join("&")
      else
        raise ArgumentError, "value must be a Hash" if prefix.nil?
        "#{prefix}=#{Rack::Utils.escape(value.to_s)}"
      end
    end
  end
end
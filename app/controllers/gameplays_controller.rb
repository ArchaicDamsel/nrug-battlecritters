require "net/http"
require 'uri'

class GameplaysController < ApplicationController

  # TODO: Welcome to the fat controller. Can we push complexity to the models?
  # index: Announce your intention to fight.
  def index
    @response = get_from_api("/apis")
    gameplay = Gameplay.new

    if @response['result']  # you lose or game cannot be started
      check_for_winner @response
      gameplay.result = @response['result']
      @destination = finish_url
    else
      @animal.update_attribute :current_role, @response["animal"]
      gameplay.board_width = @response['board'][0]
      gameplay.board_height = @response['board'][1]
      gameplay.pieces_json = @response['pieces'].to_json

      if @response['ready_to_go']
        @destination = new_url
      else
        @destination = index_url # Waiting for second player
      end
    end

    gameplay.save
  end

  # new: set up your board
  def new
    @gameplay = Gameplay.current
    @pieces = JSON.parse @gameplay.pieces_json
    positions = {
      :vertical => @pieces.each_with_index.map {|item, index| [item, index, 0]}.to_json,
      :horizontal => []
    }
    @response = post_to_api("/apis/#{@animal.current_role}", :positions => positions)
    @destination = edit_url
  end

  # edit: shoot the opponent
  def edit
    @gameplay = Gameplay.current    
    width, height = @gameplay.board_width, @gameplay.board_height
    @shot = [rand(width), rand(height)]
    @present_shot = put_to_api("/apis/#{@animal.current_role}", :shot => @shot)

    if @present_shot['winner']
      check_for_winner @present_shot
      @destination = finish_url
    else
      @destination = edit_url
    end
  end

  # finish: pretty self-explainatory.
  def finish
    @winner = Player.winner
  end

  private

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


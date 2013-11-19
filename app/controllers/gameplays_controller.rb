require "net/http"
require 'uri'

class GameplaysController < ApplicationController

  before_filter :get_my_animal

  # TODO: Welcome to the fat controller. Can we push complexity to the models?
  def index
    response = get_from_api("/apis")
    gameplay = Gameplay.new

    if response['result']  # you lose or game cannot be started
      @destination = gameplays_finish_path
      gameplay.result = response['result']
    else
      @destination = gameplays_new_path
      @animal.update_attribute :current_role, response["animal"]
      gameplay.board_width = response['board'][0]
      gameplay.board_height = response['board'][1]
      gameplay.pieces_json = response['pieces'].to_json
    end

    gameplay.save
  end

  def new
    @gameplay = Gameplay.current
    @pieces = JSON.parse @gameplay.pieces_json
    positions = {
      :vertical => @pieces.each_with_index.map {|item, index| [item, index, 0]},
      :horizontal => []
    }
    response = put_to_api("/apis/#{@animal.current_role}", :positions => positions)
    @destination = gameplays_new_path
  end

  def edit
    @destination = gameplays_edit_path
    put_to_api("/apis/#{@animal.current_role}", :shot => [0,0])
  end

  def finish
    @destination = gameplays_finish_path
  end

  private

  def get_my_animal
    @animal = Player.current_animal @my_hostname
  end

  def connect_to_api(path)
    @api = SimpleHttp.new(Server.main.hostname + path)
    @api.register_response_handler Net::HTTPResponse do |request, response, other|
      response.body
    end
  end

  def get_from_api(path) 
    connect_to_api path
    JSON.parse @api.get
  end

  def put_to_api(path, data)
    url = URI.parse('http://' + Server.main.hostname + path)
    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data data
    output = Net::HTTP.new(url.hostname, url.port).start {|http| http.request(req)}
    JSON.parse output.body
  end

  def post_to_api(path, data)
    uri = URI.parse('http://' + Server.main.hostname + path)
    req = Net::HTTP.post_form(uri, data)
    JSON.parse req.body
  end
end


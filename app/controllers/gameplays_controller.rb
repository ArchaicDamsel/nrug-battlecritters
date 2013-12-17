require "net/http"
require 'uri'

class GameplaysController < ApplicationController
  include Concerns::Gameplay

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
    Shots.delete_all
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
    
    @shots = Shot.all  

    if @shots.empty?
      @shot = [rand(@gameplay.board_width), rand(@gameplay.board_height)]
    else

    end
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

end


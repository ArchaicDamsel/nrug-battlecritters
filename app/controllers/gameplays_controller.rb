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
    @pieces = JSON.parse @gameplay.pieces_json

    vertical, horizontal = [], []

    @pieces.each_with_index do |piece, index|
      vertical << [piece, index, index] if index % 2 == 0
      horizontal << [piece, index, @gameplay.board_height - index] if index % 2 != 0
    end

    positions = {
      :vertical => vertical.to_json,
      :horizontal => horizontal.to_json
    }

    @response = post_to_api("/apis/#{@animal.current_role}", :positions => positions)
    @destination = edit_url
  end

  # edit: shoot the opponent
  def edit
    @gameplay = Gameplay.current
    combos = -> { (0..7).to_a.repeated_permutation(2).to_a.shuffle.to_json }
    @gameplay.shots_json ||= combos[]
    @shots = JSON.parse @gameplay.shots_json
    @shot = @shots.pop

    @gameplay.shots_json = @shots.empty? ? combos[] : @shots.to_json
    @gameplay.save!

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


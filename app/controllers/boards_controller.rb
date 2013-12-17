class BoardsController < ApplicationController
  def index
    redirect_to boards_show_path if Player.fox && Player.badger
  end

  def show
    @badger_board = Player.badger.board
    @fox_board = Player.fox.board
    @winner = Player.winner

    if @winner
      @timer = 20
      @timer = params[:timer].to_i - 1 if params[:timer]
    end
  end
end

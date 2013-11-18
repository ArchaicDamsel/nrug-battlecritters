class ServerApi::BoardsController < ApplicationController
  before_filter :find_model

  # Entry point: Please sir, can I play?
  def index
    url = params[:url]
    if Player.fox.nil?
      player = Player.create_fox(url)
    elsif Player.badger.nil?
      player = Player.create_badger(url)
    else
      raise "You cannot play - too many players already"
    end

    render :text => {:animal => player.current_role}
  end

  private
  def find_model
    @model = Boards.find(params[:id]) if params[:id]
  end
end
class ServerApi::BoardsController < ApplicationController
  before_filter :find_model

  # Entry point: Please sir, can I play?
  def index
    url = params[:url]
    if Server.find_by_current_role('fox').nil?
      player = Server.find_or_create_by(:hostname => url).update_attribute :current_role, 'fox'
    elsif Server.find_by_current_role('badger').nil?
      player = Server.find_or_create_by(:hostname => url).update_attribute :current_role, 'badger'
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
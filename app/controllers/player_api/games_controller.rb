class PlayerApi::GamesController < ApplicationController
  before_filter :find_model

  

  private
  def find_model
    @model = Games.find(params[:id]) if params[:id]
  end
end
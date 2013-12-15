class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :find_or_create_uuid_and_decide_team

  def find_or_create_uuid_and_decide_team
    @uuid = params[:uuid] || generate_uuid
    decide_team
  end

  def generate_uuid
    "UUID-" + rand(0..999).to_s(16) + rand(0..999).to_s(16)
  end

  def decide_team
    @animal = Player.current_animal @uuid
    @my_team = @animal ? @animal.current_role : 'Unknown'
  end
end

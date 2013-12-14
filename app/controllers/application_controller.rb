class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :find_or_create_uuid, :decide_team

  def find_or_create_uuid
    @uuid = params[:uuid] || generate_uuid
  end

  def generate_uuid
    "UUID-" + rand(0..999).to_s(16) + rand(0..999).to_s(16)
  end

  def decide_team
    server = Server.find_by(:hostname, @uuid) 
    @my_team = server ? server.current_role : 'Unknown'
  end
end

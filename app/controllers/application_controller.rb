class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :find_my_hostname, :decide_team

  def find_my_hostname
    my_port = request.port == 80 ? '' : ":#{request.port}"
    @my_hostname = "#{request.host}#{my_port}"
  end

  def decide_team
    server = Server.find_by(:hostname, find_my_hostname) 
    @my_team = server ? server.current_role : 'Unknown'
  end
end

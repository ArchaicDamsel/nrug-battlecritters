class WelcomesController < ApplicationController
  def index
    
  end

  # Warning: This is an ABUSE of restful routing.
  def new
    setup_current_server

    @other_servers = Server.where.not :hostname => @my_hostname
  end

  def create
    Server.where(:current_role => 'server').each do |old_server|
      old_server.update_attribute :current_role, ''
    end

    Server.find_or_create_by(:hostname => params[:server][:hostname]).update_attribute :current_role, 'server'
    redirect_to welcome_path
  end

  def show
    
  end


  private

  def setup_current_server
    params[:server][:hostname] = @my_hostname
    permitted_params = params.permit(:server => [:current_role, :hostname])
    @role = params[:server][:current_role]
    Server.find_or_create_by permitted_params[:server]
  end
end

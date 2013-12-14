class ApisController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  # Entry point: Please sir, can I play?
  def index
    url = request.remote_ip

    if Player.fox.nil? || Player.fox.hostname == url
      player = Player.create_fox(url)
    elsif Player.badger.nil? || Player.badger.hostname == url
      player = Player.create_badger(url)
    else
      player = nil
    end

    if player 
      @out = {:animal => player.current_role, :board => [8,8], :pieces => generate_pieces, :ready_to_go => player.has_opponent?}
      render :text => @out.to_json
    else
      @out = { :result => "Too late: Sorry someone has beat you to it" }
      render :text => @out.to_json, :status => 500
    end
  end

  def show
    if !Player.fox || !Player.badger
      @out = {:waiting_for => "other players"}
    else
      fox, badger = Player.fox, Player.badger
      if !fox.board || !badger.board
        @out = {:waiting_for => "initial positions"}
      elsif Player.game_over?
        if fox.loser? && badger.loser?
          @out = {:waiting_for => "next game", :result => "Both teams lost"}
        else
          @out = {:waiting_for => "next game", :result => "#{Player.winner.current_role} won"}
        end
      end
    end
    render :text => @out.to_json
  end

  def create
    @out = {:result => 'Success: You are ready to play!'}
    @animal = Player.find_by_animal(params[:animal])
    if @animal.nil?
      @out = { :result => 'No such animal: You need to call the index action first.'}
      @error = true
    elsif !unparse_position_parameters
      @out = { :result => 'Missing positions: either positions[horizontal] or positions[vertical] must a string of json representing a 2d array. Recieved ' + params.inspect }
      @error = true
    elsif attempting_to_place_incorrect_pieces?
      @out = { :result => "Incorrect pieces: You were given #{generate_pieces.inspect} and tried to place #{@piece_names}" }
      @error = true
    elsif @animal.board
      @out = { :result => 'Repeated setup: You must not create multiple boards for the same player' }
      @error = true
    else
      board = Board.new
      @animal.board = board
      @animal.save

      fill_board_from_params board
    end

    if @error
      @animal.update_attribute :loser, true if @animal
      @animal.opponent.update_attribute :winner, true if @animal && @animal.opponent
      render :text => @out.to_json, :status => 500
    else
      render :text => @out.to_json
    end
  end

  def update
    @animal = Player.find_by_animal(params[:animal])
    if @animal.still_playing?
      x, y = params[:shot].map &:to_i

      if @animal.nil?
        @out = { :result => 'No such animal: You need to call the index and create actions first.'}
        @error = true
      elsif Player.game_over?
        @out = {:result => @animal.won? ? "win" : "lose"}
        @error = true
      else
        board = @animal.opponent.board
        cell = board.get_cell x, y
        if cell.nil? || cell == @animal.missile_string
          board.fill_cell x, y, @animal.missile_string
          @out = {:result => 'miss'}
        elsif cell[@animal.opponent.current_role] # match substring in case we've hit this cell before
          board.fill_cell x, y, @animal.opponent.killed_string
          @out = {:result => 'hit'}
        end
      end
    else
      @out = {:result => @animal.won? ? "win" : "lose"}
    end

    if @error
      render :text => @out.to_json, :status => 500
    else
      render :text => @out.to_json
    end
  end

  private
  def generate_pieces
    [5,4,3,2,1]
  end

  def unparse_position_parameters
    return false if params[:positions].nil?
    return false unless params[:positions][:horizontal].is_a?(String) or params[:positions][:vertical].is_a?(String)
    params[:positions][:horizontal] = JSON.parse params[:positions][:horizontal] if params[:positions][:horizontal]
    params[:positions][:vertical] = JSON.parse params[:positions][:vertical] if params[:positions][:vertical]
    return params[:positions][:horizontal] || params[:positions][:vertical]
  rescue Exception => e
    return false
  end

  def attempting_to_place_incorrect_pieces?
    params[:positions][:horizontal] ||= []
    params[:positions][:vertical] ||= []

    placed_pieces = params[:positions][:horizontal]  + params[:positions][:vertical]

    @piece_names = placed_pieces.map(&:first).map(&:to_i)

    generate_pieces.sort != @piece_names.sort
  end

  def fill_board_from_params(board)
    params[:positions][:vertical].each do |length, x, y|
      length.to_i.times do |relative_position|
        board.fill_cell!(x.to_i, y.to_i + relative_position, @animal.current_role)
      end
    end
    params[:positions][:horizontal].each do |length, x, y|
      length.to_i.times do |relative_position|
        board.fill_cell!(x.to_i + relative_position, y.to_i, @animal.current_role)
      end
    end
    board.save
  rescue Board::LayoutError => e
    @error = true
    @out = { :result => e.message }
  end
end
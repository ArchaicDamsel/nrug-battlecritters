class ApisController < ApplicationController
  before_filter :find_model

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
      @out = {:animal => player.current_role, :board => [8,8], :pieces => generate_pieces}
      render :text => @out.to_json
    else
      @out = { :result => "Too late: Sorry someone has beat you to it" }
      render :text => @out.to_json, :status => 500
    end
  end

  def create
    @out = {:result => 'Success: You are ready to play!'}
    @animal = Player.find_by_animal(params[:animal])

    if @animal.nil?
      @out = { :result => 'No such animal: You need to call the index action first.'}
      @error = true
    elsif params[:positions].nil? or params[:positions][:horizontal].nil? or params[:positions][:vertical].nil?
      @out = { :result => 'Missing positions: positions[horizontal] and positions[vertical] must be arrays' }
      @error = true
    elsif (params[:positions][:horizontal] + params[:positions][:vertical]).count < generate_pieces.length
      @out = { :result => 'Too few: Not all your pieces were placed' }
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
      @animal.opponent.update_attribute :winner, true if @animal && @animal.opponent
      render :text => @out.to_json, :status => 500
    else
      render :text => @out.to_json
    end
  end

  def update
    @animal = Player.find_by_animal(params[:animal])
    x, y = params[:shot].map &:to_i

    if @animal.nil?
      @out = { :result => 'No such animal: You need to call the index action first.'}
      @error = true
    elsif Player.winner
      @out = {:result => @animal.winner? ? "win" : "lose"}
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

    if @error
      render :text => @out.to_json, :status => 500
    else
      render :text => @out.to_json
    end
  end

  private
  def find_model
    @model = Boards.find(params[:id]) if params[:id]
  end

  def generate_pieces
    [5,4,3,2,1]
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
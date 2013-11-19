require 'test_helper'

describe ApisController do
  context "Starting the game" do
    before do
      get :index
      @returned_data = JSON.parse response.body
    end

    it "should create fox" do
      expect { @returned_data["animal"] == 'fox' }
    end

    it "should create badger" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      get :index
      @returned_data = JSON.parse response.body
      expect { @returned_data["animal"] == 'badger' }
    end

    it "should allow no more players" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      get :index
      @request.env['REMOTE_ADDR'] = '1.2.3.5'
      get :index
      expect { response.status == 500 }
      expect { JSON.parse(response.body)["result"] =~ /too late/i }
    end

    it "should indicate the board size" do
      expect { @returned_data["board"] == [8,8] }
    end

    it "should indicate the pieces available" do
      expect { @returned_data["pieces"] == [5,4,3,2,1] }
    end
  end

  context "Waiting for players" do
    it "should indicate that players have not connected" do
      get :index
      get :show, :animal => "fox"
      @returned_data = JSON.parse response.body
      expect { @returned_data['waiting_for'] == 'other players'}
    end

    it "should indicate players are ready to position pieces" do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      get :index
      @request.env['REMOTE_ADDR'] = '1.2.3.5'
      get :index
      get :show, :animal => "fox"
      @returned_data = JSON.parse response.body
      expect { @returned_data['waiting_for'] == "initial positions"}
    end

  end

  context "laying out my board" do
    before do 
      get :index
      @animal_data = JSON.parse response.body
      @available_pieces = @animal_data['pieces']
      @board_dimensions = @animal_data['board']

      @overlapping_layout = { 
        :horizontal => @available_pieces.each_with_index.map {|piece, index| [piece, index, 0] }, 
        :vertical => []
      }

      @good_layout =  { 
        :horizontal => [], 
        :vertical => @available_pieces.each_with_index.map {|piece, index| [piece, 0, index] }
      }
    end

    it "should reject a board without pieces" do
      post :create, {:animal => :fox}
      expect { response.status == 500 }
      expect { JSON.parse(response.body)["result"] =~ /missing positions/i }
    end

    it "should reject a board with too few pieces" do
      post :create, {:animal => :fox, :positions => {:horizontal => [], :vertical => []}}
      expect { response.status == 500 }
      expect { JSON.parse(response.body)["result"] =~ /too few/i }
    end

    it "should reject a board with wrong pieces" do
      skip
      post :create, {:animal => :fox, :positions => {:horizontal => [], :vertical => []}}
      expect { response.status == 500 }
      expect { JSON.parse(response.body)["result"] =~ /too few/i }
    end

    it "should reject a second board layout" do
      post :create, {:animal => :fox, :positions => @good_layout}
      post :create, {:animal => :fox, :positions => @good_layout}

      expect { response.status == 500 }
      expect { JSON.parse(response.body)["result"] =~ /repeated setup/i }
    end

    it "should reject non-existant animal" do
      post :create, {:animal => :badger}
      expect { response.status == 500 }
      expect { JSON.parse(response.body)["result"] =~ /no such animal/i }
    end

    it "should reject a board with overlapping pieces" do
      post :create, :animal => :fox, :positions => @overlapping_layout

      expect { JSON.parse(response.body)["result"] =~ /overlap/i }
    end
  end

  context "shooting woodland creatures" do

    context "with bad setup" do
      before do
        ['1.2.3.4', '2.4.6.8'].each do |hostname|
          @request.env['REMOTE_ADDR'] = hostname
          get :index
          @animal_data = JSON.parse response.body
          @animal = @animal_data['animal']
          @available_pieces = @animal_data['pieces']
          @board_dimensions = @animal_data['board']

          @bad_layout =  { 
            :horizontal => [], 
            :vertical => @available_pieces.each_with_index.map {|piece, index| [piece, 0, index] }
          }

          post :create, {:animal => @animal, :positions => @bad_layout}
        end
      end

      it "should refuse to shoot" do
        put :update, {:animal => @animal, :shot => [0,0]}
        expect { response.status == 500 }
        expect { JSON.parse(response.body)["result"] =~ /(win|lose)/i }
      end
    end

    context "with good setup" do
      before do
        ['1.2.3.4', '2.4.6.8'].each do |hostname|
          @request.env['REMOTE_ADDR'] = hostname
          get :index
          @animal_data = JSON.parse response.body
          @animal = @animal_data['animal']
          @available_pieces = @animal_data['pieces']
          @board_dimensions = @animal_data['board']

          @good_layout =  { 
            :horizontal => [], 
            :vertical => @available_pieces.each_with_index.map {|piece, index| [piece, index, 0] }
          }

          post :create, {:animal => @animal, :positions => @good_layout}
        end
      end

      it "should register a miss on an empty square" do
        put :update, {:animal => @animal, :shot => [7,7]}
        expect { response.status == 200 }
        expect { JSON.parse(response.body)["result"] =~ /miss/i }
      end

      it "should register a hit on a filled square" do
        put :update, {:animal => @animal, :shot => [0,0]}
        expect { response.status == 200 }
        expect { JSON.parse(response.body)["result"] =~ /hit/i }
      end
    end
  end
end

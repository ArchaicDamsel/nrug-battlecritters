require 'test_helper'

describe GameplaysController do
  context "Starting the game" do
    before do
      Server.create! :hostname => 'zzzz', :current_role => 'server'
      Server.create! :hostname => 'abcd', :current_role => 'fox'
      Server.create! :hostname => 'efgh', :current_role => 'badger'

    end

    it "should successfully shoot" do
      stub_shot_with 0,0, :result => 'win'
      get :edit, :uuid => 'abcd'
      expect { response.status == 200 }
    end
  end

  def stub_shot_with(x, y, response)
      stub_request(:put, "http://zzzz/apis/fox?uuid=abcd").
  with(:body => "shot[]=#{x}&shot[]=#{y}",
       :headers => {'Host'=>'zzzz', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => response.to_json, :headers => {})
  end
end

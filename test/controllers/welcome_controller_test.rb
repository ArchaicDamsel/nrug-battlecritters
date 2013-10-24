require 'test_helper'

describe WelcomeController do
  it "should route the root to welcome#index " do
    assert_routing '/', {controller: "welcome", action: "index"}
  end

  context 'the index action' do
    before do
      get :index
    end

    it "should respond with a success code" do
      expect { response.code == '200'}
    end
  end
end

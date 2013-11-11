require 'test_helper'

describe WelcomesController do
  it "should route the root to welcome#index " do
    assert_routing '/', {controller: "welcomes", action: "index"}
  end

  context 'the index action' do
    before do
      get :index
    end

    it "should respond with a success code" do
      expect { response.code == '200'}
    end
  end

  context 'the create action' do
    before do
      @post = lambda do
        @request.headers[:host] = "foo"
        post :create, :server => { :hostname => 'bar' }
      end
    end

    it "should set up a server with the server role in the database" do
      (old_server_should_be_unset = Server.new).expects(:update_attribute).with(:current_role, '')
      (server_should_be_set = Server.new).expects(:update_attribute).with(:current_role, 'server')

      Server.stubs(:where).with(:current_role => 'server').returns([old_server_should_be_unset])
      Server.stubs(:find_or_create_by).with(:hostname => 'bar').returns(server_should_be_set)
      
      @post[]
    end
  end
end

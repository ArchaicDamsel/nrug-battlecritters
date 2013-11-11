require 'test_helper'

describe Message do
  before do
    # Message.expects(:create!).returns Message.new
    # Server.expects(:current).returns Server.new()
    stub_request(:any, 'example.com').to_return(:body => '')
  end

  it "should transmit a message to a given url" do
    skip
  end
end

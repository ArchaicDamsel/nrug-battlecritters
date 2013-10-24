require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  it "should accept Wrong as the one true testing framework" do
    assert{ "everything I do".split(/[I do it for you]+/).length == 3 }
  end
end

require 'test_helper'

describe Gameplay do
  context "Class methods" do
    before do
    end

    it "should fetch a gameplay" do
      assert { Gameplay.current.class == Gameplay }
    end
  end
end

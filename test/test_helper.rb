ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'wrong'
require 'mocha/setup'

# Let's ignore years of tradition when it makes sense to, ok?
Wrong.config.alias_assert :expect

class ActiveSupport::TestCase
  include Wrong
  ActiveRecord::Migration.check_pending!


  class << self
    alias_method :context, :describe
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'awesome_print'
require 'simplecov'
require 'minitest'

# NOTE: Call this _before_ requiring any gem code.
SimpleCov.start do
  add_filter /\/test\//
end  if (ENV['COVERAGE'])

require 'adventure_rl'

module TestHelper
  AP_OPTIONS = {
    plain:  true,
    indent: 2
  }

  def get_data value
    return value.ai(AP_OPTIONS)
  end
end

class UnitTest < Minitest::Test
  include AdventureRL
  include TestHelper
end

Minitest.autorun

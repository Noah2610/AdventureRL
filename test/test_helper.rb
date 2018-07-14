$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'awesome_print'
require 'AdventureRL'
include AdventureRL

module TestHelper
  AP_OPTIONS = {
    plain:  true,
    indent: 2
  }

  def get_data value
    return value.ai(AP_OPTIONS)
  end
end

require 'minitest/autorun'

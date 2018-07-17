class SettingsTest < UnitTest
  def setup
    content = {
      key_symbol:        :symbol,
      'key_string'   =>  :string,
      [:key, 'array'] => :array
    }
    @content_expected = {
      key_symbol:        :symbol,
      key_string:        :string,
      [:key, 'array'] => :array
    }
    @settings = Settings.new content
  end

  def test_that_returns_proper_content
    assert_equal @content_expected, @settings.get, 'Should return content with properly converted keys.'
  end
end

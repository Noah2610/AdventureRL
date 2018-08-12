require 'test_helper'

class AdventureRLTest < UnitTest
  def test_that_it_has_a_version_number
    refute_nil VERSION
  end

  def test_that_dir_files_exist
    DIR.each do |key, pathname|
      assert pathname.exist?, "File or directory `#{pathname.to_path}' (`DIR[:#{key.to_s}]') should exist."
    end
  end
end

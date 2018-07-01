module AdventureRL
  class Clip
    include Helpers::Error
    DEFAULT_SETTINGS = {
      directory: nil
    }
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      validate_directory @settings[:directory]
      @settings[:directory] = Pathname.new @settings[:directory]
    end

    private

    def validate_directory directory = @settings[:directory]
      error_no_directory directory  unless (directory_exists? directory)
    end
  end
end

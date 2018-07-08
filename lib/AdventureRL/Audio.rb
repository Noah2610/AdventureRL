module AdventureRL
  class Audio < FileGroup
    AUDIO_FILENAME_REGEX = /\A\d+\.(flac|wav|ogg)\z/i
    INTERNAL_DEFAULT_SETTINGS = Settings.new({
      name:      :audio_name,
      directory: nil,
      fps:       24,
      volume:    1.0
    })
    @@default_settings = nil
    @@root_directory   = Pathname.new($0).dirname

    class << self
      # Set the root directory for the audio files directory.
      # All settings 'directory' values will be relative to this.
      # Defaults to the entry scripts (the script that was called, <tt>$0</tt>) directory.
      # Pass either a String with the directory path, or an instance of Pathname.
      def set_root_directory directory
        directory = Pathname.new directory  unless (directory.is_a? Pathname)
        @@root_directory = Pathname.new directory
      end
      alias_method :root=, :set_root_directory

      # Returns the currently set root audio files directory.
      def get_root_directory
        return @@root_directory
      end
      alias_method :root, :get_root_directory

      # Set the default Settings.
      # Pass either String to a YAML settings file,
      # or a Hash with your default settings.
      def set_default_settings settings
        default_settings = nil
        if    ([String, Pathname].include? settings.class)
          directory = settings
          directory = Pathname.new directory  unless (directory.is_a? Pathname)
          if (directory.absolute?)
            default_settings = Settings.new directory
          else
            default_settings = Settings.new get_root_directory.join(directory)
          end
        elsif (settings.is_a? Hash)
          default_settings = Settings.new settings
        end
        @@default_settings = default_settings
      end
      alias_method :default_settings=, :set_default_settings
    end


    # Initialize with either a path to a YAML settings file as a String,
    # or a Hash containing your settings.
    def initialize settings
      super
    end

    private

      # Returns this class' specific INTERNAL_DEFAULT_SETTINGS.
      def get_default_settings
        return INTERNAL_DEFAULT_SETTINGS.merge @@default_settings  if (@@default_settings)
        return INTERNAL_DEFAULT_SETTINGS
      end

      # Should return the regex which must match the filenames.
      def get_filename_regex
        return AUDIO_FILENAME_REGEX
      end
  end
end

module AdventureRL
  class Clip
    include Helpers::Error
    IMAGE_FILENAME_REGEX = /\A\d+\.(png|jpe?g)\z/i
    INTERNAL_DEFAULT_SETTINGS = Settings.new({
      directory: nil,
      fps:       24,
      name:      :clip_name
    })
    @@default_settings = nil
    @@root_directory   = Pathname.new($0).dirname

    class << self
      # Set the root directory for the images directory.
      # All settings 'directory' values will be relative to this.
      # Defaults to the entry scripts (the script that was called, <tt>$0</tt>) directory.
      # Pass either a String with the directory path, or an instance of Pathname.
      def set_root_directory directory
        directory = Pathname.new directory  unless (directory.is_a? Pathname)
        @@root_directory = Pathname.new directory
      end
      alias_method :root=, :set_root_directory

      # Returns the currently set root images directory.
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
    def initialize settings_arg
      settings   = Settings.new settings_arg
      @settings  = get_settings_with settings
      @name      = @settings.get :name
      @directory = get_image_directory_from_settings @settings
      validate_directory @directory
      @image_files = get_image_paths
    end

    # Returns the Clip's settings as <tt>AdventureRL::Settings</tt>,
    # unless <tt>*keys</tt> are given, then it returns the value of
    # <tt>@settings.get(*keys)</tt>.
    def get_settings *keys
      return @settings  if (keys.empty?)
      return @settings.get(*keys)
    end

    # Returns the Clip's name
    def get_name
      return @name
    end

    # Returns the Clip's images directory
    def get_image_directory
      return @directory
    end
    alias_method :get_directory, :get_image_directory

    # Returns an Array of the image's filepaths.
    def get_images
      return @image_files
    end

    # Returns the image filepath at index <tt>index</tt>.
    def get_image index
      return @image_files[index]
    end

    # Returns true if <tt>index</tt> image exists.
    def has_image_index? index
      return index < @image_files.size
    end

    private

    def get_settings_with custom_settings
      return get_default_settings.merge custom_settings
    end

    def get_default_settings
      return INTERNAL_DEFAULT_SETTINGS.merge @@default_settings  if (@@default_settings)
      return INTERNAL_DEFAULT_SETTINGS
    end

    def get_image_directory_from_settings settings = @settings
      directory = settings.get(:directory)
      directory = directory.to_path  if (directory.is_a? Pathname)
      return Pathname.new File.join(self.class.get_root_directory, directory)
    end

    def validate_directory directory = get_directory
      error_no_directory directory  unless (directory_exists? directory)
    end

    def get_image_paths
      return get_directory.each_child.select do |file|
        next false  unless (file.file?)
        next file.basename.to_path.match? IMAGE_FILENAME_REGEX
      end .sort do |file_one, file_two|
        number_one = file_one.basename.to_path.match(/\A(\d+)\..+\z/)[1].to_i
        number_two = file_two.basename.to_path.match(/\A(\d+)\..+\z/)[1].to_i
        next number_one <=> number_two
      end
    end
  end
end

module AdventureRL
  # This is an abstract class, which is inherited by
  # - Clip
  # - Audio
  class FileGroup
    include Helpers::Error

    # Initialize with either a path to a YAML settings file as a String,
    # or a Hash containing your settings.
    def initialize settings_arg
      settings   = Settings.new settings_arg
      @settings  = get_settings_with settings
      @name      = @settings.get :name
      @directory = get_directory_from_settings @settings
      validate_directory @directory
      @files     = get_file_paths
    end

    # Returns the settings as <tt>AdventureRL::Settings</tt>,
    # unless <tt>*keys</tt> are given, then it returns the value of
    # <tt>@settings.get(*keys)</tt>.
    def get_settings *keys
      return @settings  if (keys.empty?)
      return @settings.get(*keys)
    end

    # Returns the Clip's name.
    def get_name
      return @name
    end

    # Returns an Array of the filepaths.
    def get_files
      return @files
    end

    # Returns the filepath at index <tt>index</tt>.
    def get_file index
      return @files[index]
    end

    # Returns the set directory of files.
    def get_file_directory
      return @directory
    end
    alias_method :get_directory, :get_file_directory

    # Returns true if <tt>index</tt> file exists.
    def has_file_index? index
      return index < @files.size && index >= 0
    end
    alias_method :has_index?, :has_file_index?

    private

      def get_settings_with custom_settings
        return get_default_settings.merge custom_settings
      end

      # This method should be overwritten by the child class,
      # and return their specific <tt>INTERNAL_DEFAULT_SETTINGS</tt>.
      def get_default_settings
        return {}
      end

      def get_directory_from_settings settings = @settings
        directory = settings.get(:directory)
        directory = directory.to_path  if (directory.is_a? Pathname)
        error(
          "`:directory' key must be given in settings hash to #new."
        )  unless (directory)
        return Pathname.new File.join(self.class.get_root_directory, directory)
      end

      def validate_directory directory = get_directory
        error_no_directory directory  unless (directory_exists? directory)
      end

      def get_file_paths
        return sort_files(get_directory.each_child.select do |file|
          next false  unless (file.file?)
          next file.basename.to_path.match? get_filename_regex
        end)
      end

      def sort_files files
        return files.sort do |file_one, file_two|
          number_one = file_one.basename.to_path.match(/\A(\d+)\..+\z/)[1].to_i
          number_two = file_two.basename.to_path.match(/\A(\d+)\..+\z/)[1].to_i
          next number_one <=> number_two
        end
      end

      # This method should be overwritten by the child class.
      # It should return the regex which must match the filenames.
      def get_filename_regex
        return /\A.+\..+\z/
      end
  end
end

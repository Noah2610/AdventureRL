module AdventureRL
  class Settings
    include Helpers::Error
    attr_reader :content

    # Initialize Settings with either a string representing
    # a path to a YAML file, or a hash with your settings.
    def initialize arg
      if    ([String, Pathname].include? arg.class)  # Filepath to YAML settings file
        @file = Pathname.new arg
        validate_file_exists @file
        @content = get_file_content(@file).keys_to_sym
      elsif (arg.is_a? Hash)    # Settings hash
        @content = arg.keys_to_sym
      end
    end

    # Returns the settings, following the structure of the passed <tt>keys</tt>.
    # Similar to <tt>Hash#dig</tt>
    def get *keys
      current_content = @content
      keys.each do |key|
        key = key.to_sym  if (key.is_a? String)
        if (current_content.is_a?(Hash) && current_content[key])
          current_content = current_content[key]
        else
          current_content = nil
          break
        end
      end
      return current_content
    end

    # Merge self Settings content with other_settings Settings content.
    # Can pass unlimited optional arguments as keys.
    # If <tt>keys</tt> are given, then it will only merge the content
    # from the keys <tt>keys</tt> for both Settings instances.
    # Returns a new Settings object where the values of the <tt>keys</tt> keys
    # are its settings content.
    def merge other_settings, *keys
      error(
        'Argument needs to be an instance of `AdventureRL::Settings\'',
        "but got a `#{other_settings.class.name}'"
      )  unless (other_settings.is_a? Settings)
      return Settings.new get(*keys).merge(other_settings.get(*keys))
    end

    private

    def validate_file_exists file = @file
      error_no_file file  unless (file_exists? file)
    end

    def get_file_content file = @file
      begin
        return YAML.load_file(file.to_path) || {}
      rescue
        error "Couldn't load settings file: '#{file.to_path}'", 'Is it a valid YAML file?'
      end
    end
  end
end

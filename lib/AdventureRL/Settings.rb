module AdventureRL
  class Settings
    include Helpers::Error
    attr_reader :content

    # Initialize Settings with either a string representing
    # a path to a YAML file, or a hash with your settings.
    def initialize arg
      if    ([String, Pathname].include? arg.class)
        @file = Pathname.new arg
        validate_file_exists @file
        @content = get_file_content(@file).keys_to_sym
      elsif (arg.is_a? Hash)
        @content = arg.keys_to_sym
      elsif (arg.is_a? Settings)
        @content = arg.get
      end
    end

    # Returns the settings, following the structure of the passed <tt>keys</tt>.
    # Similar to <tt>Hash#dig</tt>
    def get *keys
      current_content = @content
      keys.each do |key|
        key = key.to_sym  if (key.is_a? String)
        if (current_content.is_a?(Hash) && !current_content[key].nil?)
          current_content = current_content[key]
        else
          current_content = nil
          break
        end
      end
      return current_content
    end

    # Merge self Settings content with other_settings Settings content or Hash.
    # Can pass unlimited optional arguments as keys.
    # If <tt>keys</tt> are given, then it will only merge the content
    # from the keys <tt>keys</tt> for both Settings instances.
    # Returns a new Settings object where the values of the <tt>keys</tt> keys
    # are its settings content.
    def merge other_settings, *keys
      merged_settings = nil
      if    (other_settings.is_a? Settings)
        merged_settings = Settings.new get(*keys).merge(other_settings.get(*keys))
      elsif (other_settings.is_a? Hash)
        merged_settings = Settings.new get(*keys).merge(other_settings)
      else
        error(
          "Argument needs to be an instance of `AdventureRL::Settings' or a Hash",
          "but got a `#{other_settings.class.name}'"
        )
      end
      return merged_settings
    end

    def each
      return get.each
    end

    private

      def validate_file_exists file = @file
        error_no_file file  unless (file_exists? file)
      end

      def get_file_content file = @file
        file = Pathname.new file  unless (file.is_a? Pathname)
        begin
          return YAML.load_file(file.to_path) || {}
        rescue
          begin
            return JSON.parse(file.read, symbolize_names: true)
          rescue
            error "Couldn't load settings file: '#{file.to_path}'", 'Is it a valid YAML or JSON file?'
          end
        end
      end
  end
end

module AdventureRL
  class Window < Gosu::Window
    include Helpers::Method

    def initialize args = {}
      default_settings = DEFAULT_SETTINGS.get :window
      @window_size = args[:size] || default_settings[:size]
      super @window_size[:width], @window_size[:height]
      return  unless (method_exists?(:setup))
      if (method_takes_arguments?(:setup))
        setup args
      else
        setup
      end
    end

    def setup args = {}
      # This method can be overwritten by user,
      # and will be called after #initialize
    end
  end
end

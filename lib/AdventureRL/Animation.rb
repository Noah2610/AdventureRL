module AdventureRL
  class Animation < Image
    DEFAULT_SETTINGS = Settings.new(
      files:     ['DEFAULT_ANIMATION_FILE.png'],
      intervals: [0.5]  # Image switch intervals in seconds.
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      image_settings = @settings.get
      image_settings[:dont_create_image] = true
      super image_settings
      @images              = get_images_from [@settings.get(:files)].flatten
      @animation_intervals = [@settings.get(:intervals)].flatten
      @timing_handler      = TimingHandler.new
      @timeout_id          = :next_image_timeout
      @current_image_index = -1
      next_image
    end

    # Call this every frame, to ensure that the animation is playing.
    def update
      @timing_handler.update
    end

    def next_image
      @current_image_index += 1
      @current_image_index  = 0  if (@current_image_index >= @images.size)
      @image = @images[@current_image_index]
      set_timeout
    end

    def set_timeout
      current_interval = get_current_interval
      @timing_handler.set_timeout(
        id:      @timeout_id,
        seconds: get_current_interval,
        method:  method(:next_image)
      )  if (current_interval)
    end

    private

      def get_images_from files
        return files.map do |file|
          next get_image_from(file)
        end
      end

      def get_current_interval
        intervals_size = @animation_intervals.size
        if (@current_image_index < intervals_size)
          return @animation_intervals[@current_image_index]
        else
          return @animation_intervals[@current_image_index - (intervals_size * (@current_image_index / intervals_size).floor)]
        end
      end
  end
end

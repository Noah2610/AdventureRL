module AdventureRL
  class Image < Mask
    include Helpers::Error

    DEFAULT_SETTINGS = Settings.new(
      file:    'DEFAULT_IMAGE_FILE.png',
      retro:   true,
      z_index: 0,
      position: {
        x: 0,
        y: 0
      },
      size: {
        width:  128,
        height: 128
      },
      origin: {
        x: :left,
        y: :top
      }
    )

    # Valid image option keys for the Gosu::Image constructor.
    IMAGE_OPTION_KEYS = [
      :tileable,
      :retro,
      :rect
    ]

    # Pass the filepath to the image as the value of the key <tt>:file</tt>
    # in your passed Settings instance or hash.
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings
      @z_index       = @settings.get :z_index
      @image_options = get_image_options_from @settings
      @image         = get_image_from @settings.get(:file)
    end

    def draw
      corner = get_corner :left, :top
      scale  = get_image_scale
      @image.draw(
        corner.x, corner.y,
        @z_index,
        scale[:x], scale[:y]
      )
    end

    private

      def get_image_options_from settings = @settings
        return IMAGE_OPTION_KEYS.map do |key|
          setting = settings.get key
          next [key, setting]  if (setting)
          next nil
        end .compact.to_h
      end

      def get_image_from file
        filepath = Pathname.new file
        error_no_file filepath  unless (file_exists? filepath)
        return Gosu::Image.new(
          filepath.to_path,
          @image_options
        )
      end

      def get_image_scale
        return {
          x: (get_size(:width).to_f  / @image.width.to_f),
          y: (get_size(:height).to_f / @image.height.to_f)
        }
      end
  end
end

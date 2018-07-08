module AdventureRL
  class ClipPlayer < FileGroupPlayer
    # Default settings for ClipPlayer.
    # Are superseded by settings passed to #new.
    DEFAULT_SETTINGS = Settings.new({
      speed: 1.0,
      loop:  true,
      mask: {
        position: {
          x: 0,
          y: 0
        },
        size: {
          width:  960,
          height: 540
        },
        origin: {
          x: :left,
          y: :top
        }
      },
      z_index: 0,
      color:   0xff_ffffff,
      image_options: {
        retro: true
      }
    })

    # Pass settings Hash or Settings as argument.
    # Supersedes DEFAULT_SETTINGS.
    def initialize settings = {}
      super
      set_mask_from get_settings(:mask)
    end

    # Returns the currently active Clip.
    # Wrapper for FileGroupPlayer#get_filegroup
    alias_method :get_clip, :get_filegroup

    # Draw the current image in the currently active Clip.
    # This should be called every frame.
    def draw
      image = get_current_file
      return  unless (image)
      scale = get_scale_for_image image
      image.draw(
        get_side(:left), get_side(:top), get_settings(:z_index),
        scale[:x], scale[:y],
        get_settings(:color)
      )
    end

    private

      # Returns this class' DEFAULT_SETTINGS.
      def get_default_settings
        return DEFAULT_SETTINGS
      end

      # Loads the image file <tt>file</tt>
      def load_file file
        if (get_current_image.is_a? Gosu::Image)
          get_current_image.insert file, 0, 0
        else
          set_current_image Gosu::Image.new(
            file,
            get_settings(:image_options)
          )
        end
      end

      # Returns the current image.
      # Wrapper for FileGroupPlayer#get_current_file
      alias_method :get_current_image, :get_current_file

      # Set a new current image.
      # Wrapper for FileGroupPlayer#set_current_file
      alias_method :set_current_image, :set_current_file

      def get_scale_for_image image = get_current_file
        return {
          x: (get_size(:width).to_f  / image.width.to_f),
          y: (get_size(:height).to_f / image.height.to_f)
        }
      end

      def set_mask_from mask
        if    (mask.is_a?(Mask))
          mask.assign_to self
        elsif (mask.is_a?(Hash))
          Mask.new(
            mask.merge(
              assign_to: self
            )
          )
        else
          error "Cannot set Point as #{mask.inspect}:#{mask.class.name} for ClipPlayer."
        end
      end
  end
end

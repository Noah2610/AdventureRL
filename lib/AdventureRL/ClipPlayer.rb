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
    AUDIO_PLAYER_METHODS = [
      :play,
      :pause,
      :resume,
      :stop,
      :reset,
      :set_current_time,
      :increase_current_time,
      :set_speed,
      :increase_speed,
      :update
    ]

    class << self
      # Returns the method names of all methods aliased to method <tt>method_name</tt>.
      def get_aliased_methods method_name
        real_method = instance_method method_name
        return instance_methods.select do |instance_method_name|
          next (
            real_method == instance_method(instance_method_name) &&
            method_name != instance_method_name
          )
        end
      end

      # Overwrite a bunch of FileGroupPlayer methods,
      # so they also handle Audio, if Clip has one.
      # See AUDIO_PLAYER_METHODS for the list of methods.
      def define_audio_player_methods
        AUDIO_PLAYER_METHODS.each do |real_method_name|
          [real_method_name, get_aliased_methods(real_method_name)].flatten.each do |method_name|
            define_method(method_name) do |*args|
              super *args
              get_audio_player.method(method_name).call(*args)  if (has_audio_player?)
              # NOTE: Write #sync_audio_player method, maybe?
              #       Should be unnecessarilty doubled work,
              #       but it would garantee that both Players are synced.
              # sync_audio_player
            end
          end
        end
      end
    end

    define_audio_player_methods

    # Pass settings Hash or Settings as argument.
    # Supersedes DEFAULT_SETTINGS.
    def initialize settings = {}
      super
      @audio_player = nil
      set_mask_from get_settings(:mask)
    end

    # Returns the current AudioPlayer, if there is one.
    def get_audio_player
      return @audio_player
    end

    # Returns true if an AudioPlayer was instantiated for this ClipPlayer.
    def has_audio_player?
      return !!get_audio_player
    end

    # Returns the currently active Clip.
    # Wrapper for FileGroupPlayer#get_filegroup
    alias_method :get_clip, :get_filegroup

    # Overwrite FileGroupPlayer#play separately from above,
    # because it should call #handle_play_for_audio_player
    # to create a new AudioPlayer, if necessary.
    def play *args
      super
      if (get_clip.has_audio?)
        handle_play_for_audio_player
        # sync_audio_player
      end
    end

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

      # Set the Mask for the ClipPlayer.
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

      # Create, change, or remove AudioPlayer,
      # depending on if the current Clip has Audio.
      def handle_play_for_audio_player
        clip = get_clip
        if    (clip.has_audio?)
          if (has_audio_player?)
            @audio_player.play clip.get_audio
          else
            @audio_player = AudioPlayer.new get_settings
            @audio_player.play clip.get_audio
          end
        elsif (has_audio_player?)
          get_audio_player.stop
        end
      end

      # Returns this class' DEFAULT_SETTINGS.
      def get_default_settings
        return DEFAULT_SETTINGS
      end
  end
end

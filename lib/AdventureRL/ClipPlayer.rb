module AdventureRL
  class ClipPlayer
    include Helpers::Error

    # Default settings for ClipPlayer.
    # Are superseded by settings passed to #initialize.
    DEFAULT_SETTINGS = Settings.new({
      speed: 1.0,
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
      @settings = DEFAULT_SETTINGS.merge settings
      set_mask_from @settings.get(:mask)
      @clips = {}
      load_clips *@settings.get(:clips)  if (@settings.get(:clips))
      @speed                    = @settings.get(:speed)
      @deltatime                = Deltatime.new
      @image_index              = 0
      @active_clip              = nil
      @active_image             = nil
      @playing                  = false
      @current_time             = 0.0
      @last_current_time        = 0.0
      @accumulated_current_time = 0.0
    end

    # Store a Clip in this ClipPlayer, so it can be
    # played <em>(see #play)</em> later using its name.
    def load_clip clip
      error(
        "Cannot load clip `#{clip.to_s}:#{clip.class.name}'",
        "Argument must be a `AdventureRL::Clip'"
      )  unless (clip.is_a? Clip)
      @clips[clip.get_name] = clip
    end
    alias_method :<<, :load_clip

    # Load multiple clips.
    def load_clips *clips
      clips.each do |clip|
        load_clip clip
      end
    end

    # Returns the Clip instance with name <tt>clipname</tt>.
    def get_clip clipname
      return @clips[clipname]
    end

    # Returns the currently active Clip.
    def get_active_clip
      return @active_clip
    end

    # Returns the current playback time of the Clip in seconds.
    def get_current_time
      return @current_time
    end

    # Returns current playback speed multiplier.
    def get_speed
      return @speed
    end

    # Set playback speed multiplier.
    def set_speed speed
      error(
        'Argument passed to #set_speed must be a Float or Integer, but got',
        "#{speed.to_s}:#{speed.class.name}"
      )  unless ([Float, Integer].include? speed.class)
      @speed = speed
    end

    # Increment (or decrement) the speed value by <tt>amount</tt>.
    def increment_speed amount
      error(
        'Argument passed to #increment_speed must be a Float or Integer, but got',
        "#{seconds.to_s}:#{amount.class.name}"
      )  unless ([Float, Integer].include? amount.class)
      @speed += amount
    end
    alias_method :increase_speed, :increment_speed

    # Start playing loaded Clip with the name <tt>clipname</tt>.
    # <tt>clipname</tt> can either be the name
    # of a previously loaded <em>(see #load_clip)</em> Clip,
    # or an instance of Clip.
    def play clipname
      if (clipname.is_a? Clip)
        load_clip clipname
        set_active_clip clipname
      else
        clip = get_clip clipname
        set_active_clip clip
      end
      @playing = true
      @deltatime.reset
    end

    # Pause the currently playing Clip.
    # It will keep drawing the current Clip image if
    # #draw continues to be called.
    def pause
      @playing = false
    end

    # Resumes playing paused Clip.
    def resume
      error(
        'Cannot resume playing, there is no currently active Clip.'
      )  unless (has_active_clip?)
      @playing = true
      @deltatime.reset
    end

    # Calls #resume if Clip is paused,
    # or calls #pause if Clip is playing.
    def toggle
      if    (is_playing?)
        pause
      elsif (has_active_clip?)
        resume
      end
    end

    # Stop playing and clear active Clip.
    # Cannot call #resume after this,
    # before calling #play again.
    def stop
      @active_clip = nil
      @playing     = false
    end

    # Draw the current image in the currently active Clip.
    # Switch to the next image automatically when enough time passes.
    def draw
      draw_current_image
      return  unless (is_playing?)
      set_image_index
      @current_time             += @deltatime.dt * @speed
      @accumulated_current_time += @current_time - @last_current_time
      @last_current_time         = @current_time
      @deltatime.update
    end
    alias_method :update, :draw

    # Returns <tt>true</tt> if the Clip is currently _playing_,
    # and <tt>false</tt> if it is _paused_ or there is no active Clip.
    def is_playing?
      return @playing
    end

    # Seek forwards or backwards <tt>seconds</tt> seconds.
    def seek seconds
      error(
        'Argument passed to #seek must be a Float or Integer, but got',
        "#{seconds.to_s}:#{seconds.class.name}"
      )  unless ([Float, Integer].include? seconds.class)
      @current_time += seconds
    end

    # Reset the Clip; start playing from the start again.
    def reset
      @current_time = 0.0
      @image_index  = 0
      set_active_image
    end

    private

      def has_active_clip?
        return !!get_active_clip
      end

      def set_image_index
        target_frame_delay = 1.0 / get_active_clip.get_settings(:fps).to_f
        previous_index = @image_index
        index = (get_current_time / target_frame_delay).floor
        return  if (previous_index == index)
        @image_index = index
        unless (get_active_clip.has_image_index? @image_index)
          if (get_active_clip.get_settings(:loop))
            reset
          else
            stop
          end
          return
        end
        set_active_image
      end

      def draw_current_image
        image = get_active_image
        return  unless (image)
        scale = get_scale_for_image image
        image.draw(
          get_side(:left), get_side(:top), @settings.get(:z_index),
          scale[:x], scale[:y],
          @settings.get(:color)
        )
      end

      def get_active_image
        return @active_image
      end

      def get_scale_for_image image = get_active_image
        return {
          x: (get_size(:width).to_f  / image.width.to_f),
          y: (get_size(:height).to_f / image.height.to_f)
        }
      end

      def set_active_image
        clip = get_active_clip
        return  if (
          !clip ||
          !clip.has_image_index?(@image_index)
        )
        image_file = clip.get_image(@image_index).to_s
        if (@active_image.is_a? Gosu::Image)
          @active_image.insert image_file, 0, 0
        else
          @active_image = Gosu::Image.new(
            image_file,
            @settings.get(:image_options)
          )
        end
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
          error "Cannot set Point as `#{mask.to_s}:#{mask.class.name}' for ClipPlayer."
        end
      end

      def set_active_clip clip
        @image_index = 0
        @active_clip = clip
        set_active_image
      end
  end
end

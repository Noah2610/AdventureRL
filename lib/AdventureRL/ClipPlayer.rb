module AdventureRL
  class ClipPlayer
    include Helpers::Error

    # Default settings for ClipPlayer.
    # Are superseded by settings passed to <tt>#initialize</tt>.
    DEFAULT_SETTINGS = Settings.new({
      speed: 1,
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

    # Pass settings Hash or <tt>AdventureRL::Settings</tt> as argument.
    # Supersedes <tt>DEFAULT_SETTINGS</tt>.
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      set_mask_from @settings.get(:mask)
      @clips = {}
      load_clips *@settings.get(:clips)  if (@settings.get(:clips))
      @deltatime      = Deltatime.new
      @image_index    = 0
      @active_clip    = nil
      @active_image   = nil
      @playing        = false
      @accumulated_dt = 0.0
    end

    # Store a Clip in this ClipPlayer, so it can be
    # played _(see <tt>#play</tt>)_ later using its name.
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

    # Start playing loaded Clip with the name <tt>clipname</tt>.
    # <tt>clipname</tt> can either be the name
    # of a previously loaded _(see <tt>#load_clip</tt>)_ Clip,
    # or an instance of <tt>AdventureRL::Clip</tt>.
    def play clipname
      if (clipname.is_a? Clip)
        load_clip clipname
        set_active_clip clipname
      else
        clip = get_clip clipname
        set_active_clip clip
      end
      @playing = true
    end

    # Pause the currently playing Clip.
    # It will keep drawing the current Clip image if
    # <tt>#draw</tt> continues to be called.
    def pause
      @playing = false
    end

    # Resumes playing paused Clip.
    def resume
      error(
        'Cannot resume playing, there is no currently active Clip.'
      )
      @playing = true
    end

    # Stop playing and clear active Clip.
    # Cannot call <tt>#resume</tt> after this,
    # before calling <tt>#play</tt> again.
    def stop
      @active_clip = nil
      @playing     = false
    end

    # Draw the current image in the currently active Clip.
    # Switch to the next image automatically when enough time passes.
    def draw
      @deltatime.update
      @accumulated_dt += @deltatime.dt
      next_image get_next_image_amount
      #next_image          if (next_image?)
      draw_current_image  if (is_playing?)
    end

    # Returns <tt>true</tt> if the Clip is currently _playing_,
    # and <tt>false</tt> if it is _paused_ or there is no active Clip.
    def is_playing?
      return @playing
    end

    private

    def get_next_image_amount
      target_frame_delay = 1.0 / get_active_clip.get_settings(:fps).to_f
      amount = @accumulated_dt / target_frame_delay
      amount_floor = amount.floor
      @accumulated_dt -= target_frame_delay * amount_floor  if (amount > target_frame_delay)
      return amount_floor
    end

    def next_image amount
      return  if (amount == 0)
      @image_index += amount
      @image_index  = 0  unless (get_active_clip.has_image_index? @image_index)
      set_active_image
    end

    def draw_current_image
      image = get_active_image
      return  unless (image)
      scale = get_scale_for_image image
      image.draw(
        x, y, @settings.get(:z_index),
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
      return  unless (clip)
      @active_image = Gosu::Image.new(
        clip.get_image(@image_index).to_s,
        @settings.get(:image_options)
      )
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

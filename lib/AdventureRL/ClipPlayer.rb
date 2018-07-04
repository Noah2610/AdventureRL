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
      }
    })

    # Pass settings Hash or <tt>AdventureRL::Settings</tt> as argument.
    # Supersedes <tt>DEFAULT_SETTINGS</tt>.
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      set_mask_from @settings.get(:mask)
      @clips = {}
      load_clips *@settings.get(:clips)  if (@settings.get(:clips))
      @deltatime   = Deltatime.new
      @image_index = 0
      @active_clip = nil
      @playing     = false
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
    end

    private

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
    end
  end
end

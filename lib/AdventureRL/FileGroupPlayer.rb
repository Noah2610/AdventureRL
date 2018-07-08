module AdventureRL
  # This is an abstract class, which is inherited by
  # - ClipPlayer
  # - AudioPlayer
  # At its core, it takes a FileGroup in its #play method,
  # and <em>"plays"</em> it.
  class FileGroupPlayer
    include Helpers::Error

    # Pass settings Hash or Settings as argument.
    # Supersedes the child class' <tt>DEFAULT_SETTINGS</tt>.
    def initialize settings = {}
      @settings = get_default_settings.merge settings
      @playing                  = false
      @speed                    = @settings.get(:speed)
      @filegroup_index          = 0
      @filegroup                = nil
      @current_file             = nil
      @current_time             = 0.0
      @last_current_time        = 0.0
      @target_frame_delay       = 1.0 / 24.0  # Default, will be overwritten in #play
      @deltatime                = Deltatime.new
    end

    # Returns the settings as <tt>AdventureRL::Settings</tt>,
    # unless <tt>*keys</tt> are given, then it returns the value of
    # <tt>@settings.get(*keys)</tt>.
    def get_settings *keys
      return @settings  if (keys.empty?)
      return @settings.get(*keys)
    end

    # Returns the currently set FileGroup.
    def get_filegroup
      return @filegroup
    end

    # Returns the current playback time in seconds.
    def get_current_time
      return @current_time
    end
    alias_method :get_time, :get_current_time

    # Returns the current playback speed multiplier.
    def get_speed
      return @speed
    end

    # Set playback speed multiplier.
    def set_speed speed
      error(
        "Argument passed to #set_speed must be a Float or Integer, but got",
        "#{speed.inspect}:#{speed.class.name}"
      )  unless ([Float, Integer].include? speed.class)
      @speed = speed
    end

    # Increment (or decrement) the speed value by <tt>amount</tt>.
    def increment_speed amount
      error(
        "Argument passed to #increment_speed must be a Float or Integer, but got",
        "#{seconds.inspect}:#{amount.class.name}"
      )  unless ([Float, Integer].include? amount.class)
      @speed += amount
    end
    alias_method :increase_speed, :increment_speed

    # Start playing FileGroup <tt>filegroup</tt>.
    def play filegroup
      error(
        "Passed argument must be an instance of FileGroup, but got",
        "#{filegroup.inspect}:#{filegroup.class.name}."
      )  unless (filegroup.is_a? FileGroup)
      set_filegroup filegroup
      @target_frame_delay = 1.0 / get_filegroup.get_settings(:fps).to_f
      @playing            = true
      @deltatime.reset
    end

    # Pause the currently playing FileGroup.
    def pause
      @playing = false
    end

    # Resumes playing paused FileGroup.
    def resume
      error(
        'Cannot resume playing, there is no currently active FileGroup.'
      )  unless (has_filegroup?)
      @playing = true
      @deltatime.reset
    end

    # Stop playing and clear active FileGroup.
    # Cannot call #resume after this,
    # before calling #play again.
    def stop
      @filegroup = nil
      @playing   = false
    end

    # Calls #resume if is paused,
    # or calls #pause if is playing.
    def toggle
      if    (is_playing?)
        pause
      elsif (has_clip?)
        resume
      end
    end

    # Returns <tt>true</tt> if is currently _playing_,
    # and <tt>false</tt> if is _paused_ or _stopped_.
    def is_playing?
      return @playing
    end

    # Seek forwards or backwards <tt>seconds</tt> seconds.
    def seek seconds
      error(
        'Argument passed to #seek must be a Float or Integer, but got',
        "#{seconds.inspect}:#{seconds.class.name}"
      )  unless ([Float, Integer].include? seconds.class)
      @current_time += seconds
    end

    # Reset the current playback.
    # Start playing from the start again.
    def reset
      @current_time    = 0.0
      @filegroup_index = 0
      set_file
    end

    # Check which file from FileGroup is supposed to be played.
    # This should be called every frame.
    def update
      return  unless (is_playing?)
      set_filegroup_index
      update_timing
    end

    private

      # This method should be overwritten by the child class,
      # and return their specific <tt>DEFAULT_SETTINGS</tt>.
      def get_default_settings
        return {}
      end

      def set_filegroup filegroup
        @filegroup_index = 0
        @filegroup       = filegroup
        set_file
      end

      def set_file
        filegroup = get_filegroup
        return  if (
          !filegroup ||
          !filegroup.has_index?(get_filegroup_index)
        )
        load_file filegroup.get_file(get_filegroup_index).to_s
      end

      # This method should be overwritten by the child class.
      # It is passed the filepath <tt>file</tt>.
      def load_file file
      end

      def has_filegroup?
        return !!get_filegroup
      end

      def get_filegroup_index
        return @filegroup_index
      end
      alias_method :get_index, :get_filegroup_index

      def set_filegroup_index
        previous_index = get_filegroup_index
        index = (get_current_time / @target_frame_delay).floor
        return  if (previous_index == index)
        @filegroup_index = index
        filegroup = get_filegroup
        unless (filegroup.has_index? get_filegroup_index)
          if (get_settings(:loop))
            reset
          else
            stop
          end
          return
        end
        set_file
      end

      def update_timing
        @current_time += @deltatime.dt * @speed
        @deltatime.update
      end

      def get_current_file
        return @current_file
      end

      def set_current_file new_file
        @current_file = new_file
      end
  end
end

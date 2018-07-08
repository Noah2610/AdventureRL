module AdventureRL
  class AudioPlayer < FileGroupPlayer
    # Default settings for AudioPlayer.
    # Are superseded by settings passed to #new.
    DEFAULT_SETTINGS = Settings.new({
      speed:     1.0,
      loop:      false,
      max_speed: 10.0
    })

    # Pass settings Hash or Settings as argument.
    # Supersedes DEFAULT_SETTINGS.
    def initialize settings = {}
      super
    end

    # Returns the currently active Audio.
    # Wrapper for FileGroupPlayer#get_filegroup
    alias_method :get_audio, :get_filegroup

    # Overwrite FileGroupPlayer#update to set
    # a max speed limit. Don't play anymore once
    # it it greater than the max speed.
    # <tt>:max_speed</tt> can be passed to #new,
    # to overwrite the default.
    def update
      return  if (above_max_speed?)
      super
    end

    private

      # Returns true if the current playback speed is
      # above the max speed limit.
      def above_max_speed?
        return get_speed > get_settings(:max_speed)
      end

      # (Stops the last audio file,) -- Gosu cannot stop a Gosu::Sample, and that's what we're using.  
      # Loads the new audio file <tt>file</tt>,
      # and play it right away.
      def load_file file
        get_current_channel.stop  if (get_current_channel)
        sample = Gosu::Sample.new(file)
        set_current_channel sample.play(
          get_audio.get_settings(:volume),
          @speed,
          !:loop
        )
      end

      # Returns this class' DEFAULT_SETTINGS.
      def get_default_settings
        return DEFAULT_SETTINGS
      end

      # Returns the current Gosu::Channel.
      # Wrapper for FileGroupPlayer#get_current_file
      alias_method :get_current_channel, :get_current_file

      # Set a new current Gosu::Channel.
      # Wrapper for FileGroupPlayer#set_current_file
      alias_method :set_current_channel, :set_current_file
  end
end

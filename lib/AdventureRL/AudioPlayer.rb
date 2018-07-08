module AdventureRL
  class AudioPlayer < FileGroupPlayer
    # Default settings for AudioPlayer.
    # Are superseded by settings passed to #new.
    DEFAULT_SETTINGS = Settings.new({
      speed:  1.0,
      loop:   false
    })

    # Pass settings Hash or Settings as argument.
    # Supersedes DEFAULT_SETTINGS.
    def initialize settings = {}
      super
    end

    # Returns the currently active Audio.
    # Wrapper for FileGroupPlayer#get_filegroup
    alias_method :get_audio, :get_filegroup

    private

      # (Stops the last audio file,) -- Gosu cannot stop a Gosu::Sample, and that's what we're using.  
      # Loads the new audio file <tt>file</tt>,
      # and play it right away.
      def load_file file
        # NOTE: Before loading and playing a new Gosu::Sample,
        #       the previous one should be stopped, but Gosu::Sample cannot do this.
        #       Ideally, it should have finished playing when this method is called, anyway.
        set_current_audio Gosu::Sample.new(file)
        get_current_audio.play(
          get_audio.get_settings(:volume),
          get_settings(:speed),
          !:loop
        )
      end

      # Returns this class' DEFAULT_SETTINGS.
      def get_default_settings
        return DEFAULT_SETTINGS
      end

      # Returns the current audio file.
      # Wrapper for FileGroupPlayer#get_current_file
      alias_method :get_current_audio, :get_current_file

      # Set a new current audio.
      # Wrapper for FileGroupPlayer#set_current_file
      alias_method :set_current_audio, :set_current_file
  end
end

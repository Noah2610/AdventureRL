module AdventureRL
  class Deltatime
    def initialize
      @last_update_at = nil
      @deltatime      = nil
      set_last_update_at
      set_deltatime
    end

    # Returns the value of the last calculated deltatime.
    def get_deltatime
      return @deltatime
    end
    alias_method :get, :get_deltatime
    alias_method :dt,  :get_deltatime

    # Call this method every tick / frame
    # to update the deltatime value.
    def update
      set_deltatime
      set_last_update_at
    end

    # Resets last updated deltatime.
    # Used when wanting to pause this deltatime's calculations,
    # so when resumed, deltatime isn't a large number.
    def reset
      set_last_update_at
    end

    private

      def set_deltatime
        diff_in_secs = get_elapsed_seconds - @last_update_at
        @deltatime = diff_in_secs
      end

      def set_last_update_at
        @last_update_at = get_elapsed_seconds
      end

      def get_elapsed_seconds
        return Gosu.milliseconds.to_f / 1000.0
      end
  end
end

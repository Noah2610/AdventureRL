module AdventureRL
  # The TimingHandler has nice methods to handle timing.
  # It can #set_timeout or #set_interval for methods.
  class TimingHandler
    include Helpers::Error

    def initialize
      @queue = {
        timeouts:  [],
        intervals: []
      }
    end

    # #update should be called every frame,
    # this is where it checks if any methods need to be called
    # and calls them if necessary.
    def update
      handle_timeouts
      handle_intervals
    end

    # Set a timeout for a method.
    # Call a method after a specified amount of time has passed.  
    # The passed <tt>args</tt> Hash should include the following keys:
    # <tt>:method</tt>::                        The method to be called. Can be one of the following:
    #                                           - a Method                  -- <tt>method(:my_method)</tt>
    #                                           - a Proc                    -- <tt>Proc.new { puts 'My method!' }</tt>
    #                                           - a method name as a Symbol -- <tt>:my_method</tt>
    # <tt>:seconds</tt> _or_ <tt>:secs</tt>::   Integer or Float. The time to wait in seconds, before calling the method.
    # <tt>:arguments</tt> _or_ <tt>:args</tt>:: Optional Array of arguments, which will be passed to the target method.
    # <tt>:id</tt>::                            Optional value which can be used to remove the timeout afterwards. See #remove_timeout.
    # You can also pass a block to the method,
    # which will be used instead of the <tt>:method</tt> key's value.
    def set_timeout args = {}, &block
      validate_args args, !!block
      _args = get_unified_args args, &block
      at    = get_time_in _args[:seconds]
      @queue[:timeouts] << {
        method:    _args[:method],
        at:        at,
        arguments: _args[:arguments],
        id:        _args[:id]
      }
    end
    alias_method :in, :set_timeout

    # Set an interval for a method.
    # Call a method in regular intervals.  
    # The passed <tt>args</tt> Hash should include the following keys:
    # <tt>:method</tt>::                        The method to be called. Can be one of the following:
    #                                           - a Method                  -- <tt>method(:my_method)</tt>
    #                                           - a Proc                    -- <tt>Proc.new { puts 'My method!' }</tt>
    #                                           - a method name as a Symbol -- <tt>:my_method</tt>
    # <tt>:seconds</tt> _or_ <tt>:secs</tt>::   Integer or Float. The time to wait in seconds, before calling the method.
    # <tt>:arguments</tt> _or_ <tt>:args</tt>:: Optional Array of arguments, which will be passed to the target method.
    # <tt>:id</tt>::                            Optional value which can be used to remove the interval afterwards. See #remove_interval.
    # You can also pass a block to the method,
    # which will be used instead of the <tt>:method</tt> key's value.
    def set_interval args = {}, &block
      validate_args args, !!block
      _args = get_unified_args args, &block
      at    = get_time_in _args[:seconds]
      @queue[:intervals] << {
        method:    _args[:method],
        interval:  _args[:seconds],
        at:        at,
        arguments: _args[:arguments],
        id:        _args[:id]
      }
    end
    alias_method :every, :set_interval

    # If you passed an <tt>:id</tt> to your timeout when you set it with #set_timeout,
    # then you can remove / clear it before it executes by calling this method and
    # passing the same <tt>id</tt>.
    def remove_timeout id
      @queue[:timeouts].reject! do |timeout|
        next timeout[:id] == id
      end
    end
    alias_method :clear_timeout, :remove_timeout

    # If you passed an <tt>:id</tt> to your interval when you set it with #set_interval,
    # then you can remove / clear it by calling this method and
    # passing the same <tt>id</tt>.
    # If you did _not_ pass an <tt>id</tt>, then your interval will be running endlessly!
    def remove_interval id
      @queue[:intervals].reject! do |interval|
        next interval[:id] == id
      end
    end
    alias_method :clear_interval, :remove_interval

    # Returns <tt>true</tt> if the given <tt>id</tt> exists as a timeout,
    # and <tt>false</tt> if not.
    def has_timeout? id
      return @queue[:timeouts].any? do |timeout|
        next timeout[:id] == id
      end
    end

    # Returns <tt>true</tt> if the given <tt>id</tt> exists as an interval,
    # and <tt>false</tt> if not.
    def has_interval? id
      return @queue[:intervals].any? do |interval|
        next interval[:id] == id
      end
    end

    private

      def handle_timeouts
        current_seconds = get_elapsed_seconds
        @queue[:timeouts].reject! do |timeout|
          next false  unless (current_seconds >= timeout[:at])
          timeout[:method].call *timeout[:arguments]
          next true
        end
      end

      def handle_intervals
        current_seconds = get_elapsed_seconds
        @queue[:intervals].each do |interval|
          next  unless (current_seconds >= interval[:at])
          interval[:method].call *interval[:arguments]
          interval[:at] = get_time_in interval[:interval]
        end
      end

      def validate_args args, block_given = false
        error(
          "Passed argument must be a Hash."
        )  unless (args.is_a? Hash)
        unless (block_given)
          error(
            "Passed args Hash must include the key `:method'."
          )  unless (args.key? :method)
          method_class = args[:method].class
          error(
            "Key `:method' must be a Method, Proc, or Symbol, but is a `#{method_class.name}'"
          )  unless ([Method, Proc, Symbol].include? method_class)
        end
        error(
          "Passed args Hash must include the key `:seconds' or `:secs'."
        )  unless (args.key?(:seconds) || args.key?(:secs))
        seconds_key   = :secs     if (args.key? :secs)
        seconds_key   = :seconds  if (args.key? :seconds)
        seconds_class = args[seconds_key].class
        error(
          "Key `:#{seconds_key.to_s}' must be an Integer or Float, but is a `#{seconds_class.name}'"
        )  unless ([Integer, Float].include? seconds_class)
        if (args.key?(:arguments) || args.key?(:args))
          arguments_key   = :args       if (args.key? :args)
          arguments_key   = :arguments  if (args.key? :arguments)
          arguments_class = args[arguments_key].class
          error(
            "Key `:#{arguments_key.to_s}' must be an Array, but is a `#{arguments_class.name}'"
          )  unless (arguments_class == Array)
        end
      end

      def get_unified_args args, &block
        prc = get_proc_from(block || args[:method])
        return {
          method:    prc,
          seconds:   args[:seconds]   || args[:secs],
          arguments: args[:arguments] || args[:args] || [],
          id:        args[:id]
        }
      end

      def get_proc_from meth
        prc = nil
        if    (meth.is_a? Method)
          prc = meth.to_proc
        elsif (meth.is_a? Proc)
          prc = meth
        elsif (meth.is_a? Symbol)
          error(
            "Method `:#{meth.to_s}' is not available in this scope."
          )  unless (methods.include? meth)
          prc = method(meth).to_proc
        end
        return prc
      end

      def get_time_in seconds
        return get_elapsed_seconds + seconds
      end

      def get_elapsed_seconds
        return Gosu.milliseconds.to_f / 1000.0
      end
  end
end

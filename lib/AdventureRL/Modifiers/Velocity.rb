module AdventureRL
  module Modifiers
    module Velocity
      DEFAULT_VELOCITY_SETTINGS = Settings.new(
        max_velocity: {
          x: 100,
          y: 100
        },
        velocity_decay: {
          x: 10,
          y: 10
        },
        base_velocity: {
          x: 0,
          y: 0
        },
        quick_turn_around: false
      )

      def initialize settings = {}
        velocity_settings = DEFAULT_VELOCITY_SETTINGS.merge settings
        @velocity = {
          x: 0.0,
          y: 0.0
        }
        @max_velocity_original      = velocity_settings.get :max_velocity
        @max_velocity               = @max_velocity_original.dup
        @velocity_decay             = velocity_settings.get :velocity_decay
        @velocity_quick_turn_around = velocity_settings.get :quick_turn_around
        @base_velocity              = velocity_settings.get :base_velocity
        @velocity_deltatime         = Deltatime.new
        @has_increased_velocity_for = {
          x: false,
          y: false
        }
        super
      end

      # Returns the velocity.
      # Pass an optional <tt>target</tt> argument,
      # which can be either an axis (<tt>:x</tt> or <tt>:y</tt>),
      # or <tt>:all</tt>, which will return a Hash with both values.
      def get_velocity target = :all
        target = target.to_sym
        return @velocity          if (target == :all)
        return @velocity[target]  if (@velocity.keys.include?(target))
        return nil
      end

      # Returns the max velocity.
      # Pass an optional <tt>target</tt> argument,
      # which can be either an axis (<tt>:x</tt> or <tt>:y</tt>),
      # or <tt>:all</tt>, which will return a Hash with both values.
      def get_max_velocity target = :all
        target = target.to_sym
        return @max_velocity          if (target == :all)
        return @max_velocity[target]  if (@max_velocity.keys.include?(target))
        return nil
      end

      def set_velocity *args
        new_velocity = parse_position *args
        @velocity[:x] = new_velocity[:x]  if (new_velocity.key? :x)
        @velocity[:y] = new_velocity[:y]  if (new_velocity.key? :y)
      end

      # Increase the velocity.
      # <tt>args</tt> may be:
      #   Two integers, representing the <tt>x</tt> and <tt>y</tt> axes, respectively.
      #   A hash containing one or both of the keys <tt>:x</tt> and <tt>:y</tt>.
      def increase_velocity_by *args
        opts = {}
        opts = args.last  if (args.last.is_a? Hash)
        quick_turn_around = @velocity_quick_turn_around
        quick_turn_around = opts[:quick_turn_around]  unless (opts[:quick_turn_around].nil?)
        incremental_velocity = parse_position *args
        @velocity.keys.each do |axis|
          next  unless (incremental_velocity.key? axis)
          velocity_sign = @velocity[axis].sign
          incremental_velocity_sign = incremental_velocity[axis].sign
          @velocity[axis]  = 0  unless (velocity_sign == incremental_velocity_sign)  if (quick_turn_around && !opts[:no_quick_turn_around])
          @velocity[axis]  = @base_velocity[axis] * incremental_velocity_sign        if (@velocity[axis] == 0)
          @velocity[axis] += incremental_velocity[axis]
          case velocity_sign
          when 1
            @velocity[axis] = get_max_velocity(axis)   if (@velocity[axis] > get_max_velocity(axis))
          when -1
            @velocity[axis] = -get_max_velocity(axis)  if (@velocity[axis] < -get_max_velocity(axis))
          end
          @has_increased_velocity_for[axis] = true
        end
      end
      alias_method :add_velocity, :increase_velocity_by

      def set_max_velocity *args
        new_max_velocity = parse_position *args
        @max_velocity_original.keys.each do |axis|
          @max_velocity_original[axis] = new_max_velocity[axis]  if (new_max_velocity.key? axis)
        end
        @max_velocity = @max_velocity_original.dup
      end

      def set_temporary_max_velocity *args
        new_max_velocity = parse_position *args
        @max_velocity.keys.each do |axis|
          @max_velocity[axis] = new_max_velocity[axis]  if (new_max_velocity.key? axis)
        end
      end

      # Resets the max velocity to the original values.
      def reset_max_velocity
        @max_velocity = @max_velocity_original.dup
      end

      # Call this every frame to move with the stored velocity.
      def move
        move_by get_incremental_position_for_velocity  if (any_velocity?)
        decrease_velocity
        @has_increased_velocity_for = {
          x: false,
          y: false
        }
        @velocity_deltatime.update
      end

      private

        # Returns <tt>true</tt> if there is any stored velocity,
        # for any axis.
        def any_velocity?
          return @velocity.values.any? do |velocity|
            next velocity != 0
          end
        end

        def get_incremental_position_for_velocity
          return get_velocity.map do |axis, speed|
            next [axis, speed * @velocity_deltatime.dt]
          end .to_h
        end

        # Decrease the velocity, based on the decay rate
        # and deltatime.
        def decrease_velocity
          return  unless (any_velocity?)
          @velocity.keys.each do |axis|
            next  if (@velocity[axis] == 0 || @has_increased_velocity_for[axis])
            case @velocity[axis].sign
            when 1
              @velocity[axis] -= @velocity_decay[axis]
              @velocity[axis]  = 0  if (@velocity[axis] < 0)
            when -1
              @velocity[axis] += @velocity_decay[axis]
              @velocity[axis]  = 0  if (@velocity[axis] > 0)
            end
          end
        end
    end
  end
end

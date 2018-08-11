module AdventureRL
  module Modifiers
    module Gravity
      #include AdventureRL::Modifiers::Velocity  # NOTE: This modifier relies on Modifiers::Velocity

      DEFAULT_GRAVITY_SETTINGS = Settings.new(
        gravity_force:     1000.0,
        gravity_direction: {
          x: 0.0,
          y: 1.0
        }
      )

      def initialize settings = {}
        gravity_settings   = DEFAULT_GRAVITY_SETTINGS.merge settings
        @gravity           = 0.0
        @gravity_force     = gravity_settings.get :gravity_force
        @gravity_direction = gravity_settings.get :gravity_direction
        #@max_velocity = @max_velocity_original.dup
        super
        @max_velocity_original[:y] = Float::INFINITY
        @max_velocity[:y]          = @max_velocity_original[:y].dup
        @velocity_decay[:y]        = 0
      end

      # Apply gravitational force.
      def gravitize
        previous_position = get_position.dup
        get_gravity_directions.each do |axis, multiplier|
          next  if (@has_increased_velocity_for[axis])
          set_position axis => (get_position(axis) + multiplier)  unless (multiplier == 0)
          if (in_collision?)
            @velocity[axis] = 0.0
          else  #if ([0, @gravity_direction[axis].sign].include? get_velocity(axis).sign)
            increase_velocity_by(
              axis => ((@gravity_force * @gravity_direction[axis]) * @velocity_deltatime.dt),
              no_quick_turn_around: true
            )
          end
          set_position previous_position
        end
      end

      # Overwrite Modifiers::Velocity#move,
      # so we can update the gravity.
      def move
        super
        gravitize
      end

      private

        def get_gravity_directions
          return @gravity_direction.select do |axis, value|
            next value != 0
          end
        end
    end
  end
end

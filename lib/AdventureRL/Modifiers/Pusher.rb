module AdventureRL
  module Modifiers
    # A Modifiers::Pusher is a Modifers::Solid Mask,
    # which has the ability to __push other solid Masks__ (that are _not static_)
    # out of the way when moving with #move_by.
    module Pusher
      #include AdventureRL::Modifiers::Solid  # NOTE: This modifier relies on Modifiers::Solid

      # Overwrite Modifiers::Solid#move_by to add the
      # <tt>:pushed_by_pusher</tt> option.
      # This skips pushing the Pusher that pushed this Pusher,
      # to avoid an endless pushing of Pushers, where one Pusher
      # pushes the other Pusher before that Pusher pushes the first Pusher, ...
      def move_by *args
        return  if (is_static?)

        if (args.last.is_a?(Hash))
          @pushed_by_pusher = [args.last[:pushed_by_pusher], self].flatten.reject { |x| !x }
        else
          @pushed_by_pusher = [self]
        end
        super
        @pushed_by_pusher = false
      end

      private

        def move_by_handle_collision_with_previous_position previous_position
          colliding_objects = get_colliding_objects
          if (colliding_objects.any?)
            if (colliding_objects.any? &:is_static?)
              @position = previous_position
              return false
            end
            direction = get_position_difference_from previous_position
            if (push_objects(colliding_objects, direction))
              return true
            else
              @position = previous_position
              return false
            end
          end
          return true
        end

        def get_position_difference_from previous_position
          return get_position.map do |axis, position|
            next [axis, (position - previous_position[axis])]
          end .to_h
        end

        def push_objects objects, direction
          direction[:precision_over_performance] = @precision_over_performance
          return objects.all? do |object|
            next true  if (@pushed_by_pusher && @pushed_by_pusher.include?(object))
            next object.move_by(direction.merge(pushed_by_pusher: @pushed_by_pusher))
          end
        end
    end
  end
end

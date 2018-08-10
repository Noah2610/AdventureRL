module AdventureRL
  module Modifiers
    # A Modifiers::Pusher is a Modifers::Solid Mask,
    # which has the ability to __push other solid Masks__ (that are _not static_)
    # out of the way when moving with #move_by.
    module Pusher
      #include AdventureRL::Modifiers::Solid  # NOTE: This modifier relies on Modifiers::Solid

      private

        def move_by_handle_collision_with_previous_position previous_position
          colliding_objects = get_colliding_objects
          if (colliding_objects.any?)
            if (colliding_objects.any? &:is_static?)
              @position = previous_position
              return false
            end
            direction = get_moving_direction_from previous_position
            if (push_objects(colliding_objects, direction))
              return true
            else
              @position = previous_position
              return false
            end
          end
          return true
        end

        def get_moving_direction_from previous_position
          # current - previous
          return get_position.map do |axis, position|
            next [axis, (position - previous_position[axis])]
          end .to_h
        end

        def push_objects objects, direction
          return objects.all? do |object|
            next object.move_by(direction)
          end
        end
    end
  end
end

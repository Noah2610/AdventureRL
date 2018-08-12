module AdventureRL
  module Modifiers
    # This module is supposed to be <tt>include</tt>d in Mask child classes.
    # It will tag that Mask instance as <tt>'solid'</tt>,
    # and check collision with other solid Masks when calling #move_by.
    # You can give it a specific <tt>solid_tag</tt>, which can be passed as
    # the <tt>:solid_tag</tt> key's value upon initialization.
    # Multiple solid tags may be passed as an array.
    # Solid Masks will only collide with other Solid Masks that have a mutual solid tag.
    # The default solid tag is <tt>:default</tt>.
    module Solid
      # NOTE: possible <tt>:precision_over_performance</tt> values:
      # :low (or anything other than the higher values)::
      #   Lowest precision, highest performance.
      #   Never check every pixel between previous and new positions.
      #   If there is collision at new position, jump to previous position and return.
      #   The larger the movement steps, the more distance there will be to the colliding object.
      #   - -- __CANNOT__ fully close gaps to Solids.
      #   - -- __CAN__ phase through Solids at high speeds (especially when it lags).
      #   - -- __CAN__ get stuck in place temporarily when moving on both axes but only colliding on one of them.
      #   - + Only __one collision check__ per call to #move_by, highest performance.
      #
      # :medium::
      #   Medium precision, medium (varying) performance.
      #   Only checks every pixel in path if the expected destination collides.
      #   Even then, collision checking is used somewhat sparingly.
      #   - -- __CAN__ phase through Solids at high speeds (especially when it lags).
      #   - -- __CAN__ get stuck in place temporarily when moving on both axes but only colliding on one of them.
      #   - + __CAN__ _almost_ fully close gaps to Solids (no sub-pixel collision checks).
      #
      # :high::
      #   High precision, low to medium (varying) performance.
      #   Only checks every pixel in path if the expected destination collides.
      #   When checking every pixel in path, check both axes separately, to improve precision.
      #   - -- __CAN__ phase through Solids at high speeds (especially when it lags).
      #   - + __CANNOT__ get stuck in place temporarily when moving on both axes but only colliding on one of them.
      #   - + __CAN__ fully close gaps to Solids.
      #
      # :highest::
      #   Highest precision, least performance.
      #   Always check every pixel between previous and new positions.
      #   Depending on the amount of (moving) Solid objects on screen,
      #   - -- Depending on the amount of (moving) Solids,
      #     this can get very laggy at high speeds                    =>
      #     lag produces larger steps (usually), because of Deltatime =>
      #     larger steps produce more collision checks and more lag.
      #   - + __CANNOT__ phase through Solids, no matter what the speed is.
      #   - + __CANNOT__ get stuck in place temporarily when moving on both axes but only colliding on one of them.
      #   - + __CAN__ fully close gaps to Solids.
      DEFAULT_SOLID_SETTINGS = Settings.new(
        solid_tag:                  SolidsManager::DEFAULT_SOLID_TAG,
        solid_tag_collides_with:    nil,
        precision_over_performance: :medium,
        static:                     false,
        auto_update:                false
      )

      # Additionally to the Mask's settings Hash or Settings instance,
      # you may pass the extra key <tt>:solid_tag</tt>, to define
      # a custom solid tag (or multiple solid tags) upon initialization.
      # They are used for collision checking with other Solid Mask objects
      # that have a mutual solid tag.
      def initialize settings = {}
        @settings                   = DEFAULT_SOLID_SETTINGS.merge settings
        @solid_tags                 = [@settings.get(:solid_tag)].flatten.sort
        @solid_tags_collides_with   = [@settings.get(:solid_tag_collides_with) || @solid_tags].flatten.sort
        @solid_static               = @settings.get :static  # Basically disables #move_by
        @precision_over_performance = @settings.get :precision_over_performance
        assign_to_solids_manager  if (@settings.get :auto_update)
        #@solids_manager.add_object self, @solid_tags  if (@settings.get :auto_update)
        super @settings
      end

      def add_to_solids_manager solids_manager
        Helpers::Error.error(
          "Expected argument to be a SolidsManager, but got",
          "'#{solids_manager.inspect}:#{solids_manager.class.name}`."
        )  unless (solids_manager.is_a? SolidsManager)
        @solids_manager = solids_manager
        @solids_manager.add_object self, get_solid_tags
      end

      # Overwrite #set_layer method, so we can get the SolidsManager
      # from the Layer, if it has one.
      def set_layer layer
        super
        assign_to_solids_manager
      end

      # Overwrite #move_by method, so that collision checking with other objects
      # with a mutual solid tag is done, and movement prevented if necessary.
      def move_by *args
        return false  if     (is_static?)
        return super  unless (@solids_manager)

        @real_point = nil
        previous_position = get_position.dup
        incremental_position = parse_position(*args)
        expected_position = {
          x: (previous_position[:x] + (incremental_position.key?(:x) ? incremental_position[:x] : 0)),
          y: (previous_position[:y] + (incremental_position.key?(:y) ? incremental_position[:y] : 0))
        }

        # NOTE:
        # This is a bit of a hacky workaround for some
        # weird Pusher behavior with Velocity and Gravity.
        previous_precision_over_performance = @precision_over_performance.dup
        opts = args.last.is_a?(Hash) ? args.last : nil

        puts 'PUSHING'  if (is_a?(Player) && opts && opts[:pushed_by_pusher])

        @precision_over_performance = opts[:precision_over_performance]  if (opts.key? :precision_over_performance)

        if ([:highest].include? @precision_over_performance)
          move_by_steps incremental_position
        else
          @position[:x] += incremental_position[:x]  if (incremental_position.key? :x)
          @position[:y] += incremental_position[:y]  if (incremental_position.key? :y)
          unless (move_by_handle_collision_with_previous_position previous_position)
            move_by_steps incremental_position  if ([:medium, :high].include? @precision_over_performance)
          end
        end

        @precision_over_performance = previous_precision_over_performance
        @solids_manager.reset_object self, get_solid_tags  unless (@position == previous_position)
        return @position == expected_position
      end

      # Overwrite the #move_to method, so we can
      # reset the object for the solids_manager if necessary.
      def move_to *args
        previous_position = get_position.dup
        super
        return  unless (@solids_manager)
        @solids_manager.reset_object self, get_solid_tags  if (@position != previous_position)
      end

      # Returns <tt>true</tt> if this Mask is currently in collision
      # with another solid Mask which has a mutual solid tag.
      def in_collision?
        return false  unless (@solids_manager)
        return @solids_manager.collides?(self, get_solid_tags_collides_with)
      end

      # Returns all currently colliding objects (if any).
      def get_colliding_objects
        return []  unless (@solids_manager)
        return @solids_manager.get_colliding_objects(self, get_solid_tags_collides_with)
      end

      # Returns <tt>true</tt> if this is a static solid Mask,
      # which means it cannot be moved with #move_by.
      def is_static?
        return !!@solid_static
      end

      # Returns this Mask's solid tags,
      # which other Masks use to check collision against _this_ Mask.
      def get_solid_tags
        return @solid_tags
      end

      # Returns the solid tags,
      # which this Mask uses to check collision against _other_ Masks.
      def get_solid_tags_collides_with
        return @solid_tags_collides_with || @solid_tags
      end

      private

        def assign_to_solids_manager
          layer = get_layer
          return  unless (layer && layer.has_solids_manager?)
          @solids_manager = layer.get_solids_manager
          @solids_manager.add_object self, get_solid_tags  if (@solids_manager)
        end

        # This is the ugliest method in the project.
        # I can live with there being __one__ ugly method.
        # Also, it _does_ do some complicated stuff, so cut it some slack.
        # It didn't ask to be this way.
        def move_by_steps incremental_position
          incremental_position[:x] ||= 0
          incremental_position[:y] ||= 0

          larger_axis = :x  if (incremental_position[:x].abs >= incremental_position[:y].abs)
          larger_axis = :y  if (incremental_position[:y].abs >  incremental_position[:x].abs)
          smaller_axis = (larger_axis == :x) ? :y : :x
          larger_axis_sign  = incremental_position[larger_axis].sign
          smaller_axis_sign = incremental_position[smaller_axis].sign
          smaller_axis_increment_at = (incremental_position[larger_axis].abs.to_f / incremental_position[smaller_axis].abs.to_f).round  rescue nil
          remaining_values = {
            larger_axis  => ((incremental_position[larger_axis].abs  % 1) * larger_axis_sign),
            smaller_axis => ((incremental_position[smaller_axis].abs % 1) * smaller_axis_sign),
          }

          return  unless (move_by_steps_for_remaining_values remaining_values)

          # NOTE
          # We use #to_i here, because a negative float's #floor method decreases its value. Example:
          #   1.75.floor   # =>  1.0
          #   -1.75.floor  # => -2.0
          #   1.75.to_i    # =>  1.0
          #   -1.75.to_i   # => -1.0
          incremental_position[larger_axis].to_i.abs.times do |axis_index|
            initial_previous_position = @position.dup

            tmp_in_collision_count = 0

            previous_position = @position.dup
            @position[larger_axis] += larger_axis_sign
            tmp_in_collision_count += 1  unless (
              move_by_handle_collision_with_previous_position(previous_position)
            )  if ([:high, :highest].include? @precision_over_performance)

            if (smaller_axis_increment_at &&
                (((axis_index + 1) % smaller_axis_increment_at) == 0)
               )
              previous_position = @position.dup
              @position[smaller_axis] += smaller_axis_sign
              tmp_in_collision_count += 1  unless (
                move_by_handle_collision_with_previous_position(previous_position)
              )  if ([:high, :highest].include? @precision_over_performance)
            end

            return  unless (tmp_in_collision_count < 2)
            if ([:medium].include? @precision_over_performance)
              return  unless (move_by_handle_collision_with_previous_position initial_previous_position)
            end
          end
        end

        def move_by_steps_for_remaining_values remaining_values
          return true  unless ([:high, :highest].include? @precision_over_performance)
          return true  if     (remaining_values.values.all? { |val| val == 0 })
          tmp_in_collision_count = 0
          remaining_values.each do |remaining_axis, remaining_value|
            next  if (remaining_value == 0)
            previous_position = @position.dup
            @position[remaining_axis] += remaining_value
            remaining_values[remaining_axis] = 0
            unless (move_by_handle_collision_with_previous_position previous_position)
              tmp_in_collision_count += 1
              next  # break
            end
          end
          return false  if (tmp_in_collision_count == 2)  # NOTE: Slight performance improvement
          return true
        end

        # Returns <tt>true</tt> if there was no collision, and
        # returns <tt>false</tt> if there was and it had to reset to the <tt>previous_position</tt>.
        def move_by_handle_collision_with_previous_position previous_position
          if (in_collision?)
            @position = previous_position
            return false
          end
          return true
        end
    end
  end
end

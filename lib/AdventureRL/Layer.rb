module AdventureRL
  # This class is supposed to be a sort of container
  # for instances which have Mask s assigned to them.
  # It can manipulate any drawing operations, which will
  # effect all Mask s contained. See Gosu methods.
  # Layer also has a Mask.
  class Layer
    include Helpers::Error

    # Initialize Layer with a Mask.
    def initialize mask
      set_mask_from mask
      @children = []
      @scale = {
        x: 1,
        y: 1
      }
      @angle = 0
    end

    # Add any object to this Layer.
    def add object
      @children << object
    end
    alias_method :<<, :add

    # Returns all its children objects.
    def get_children
      return @children
    end

    # Set the layer scaling.
    # Pass an <tt>axis</tt>, either <tt>:x</tt> or <tt>:y</tt>,
    # and an <tt>amount</tt> as an Integer or Float.
    def set_scale axis, amount
      error(
        "Passed argument `axis' needs to be one of the following:",
        "  #{@scale.keys.map(&:inspect).join(', ')}"
      )  unless (@scale.key? axis)
      error(
        "Passed argument `amount' needs to be an Integer or Float, but got",
        "  #{amount.inspect}.#{amount.class.name}"
      )  unless ([Integer, Float].include? amount.class)
      @scale[axis] = amount
    end

    # Increase (or decrease) the layer scaling by an <tt>amount</tt>.
    # Pass an <tt>axis</tt>, either <tt>:x</tt> or <tt>:y</tt>,
    # and an <tt>amount</tt> as an Integer or Float.
    def increase_scale axis, amount
      error(
        "Passed argument `axis' needs to be one of the following:",
        "  #{@scale.keys.map(&:inspect).join(', ')}"
      )  unless (@scale.key? axis)
      error(
        "Passed argument `amount' needs to be an Integer or Float, but got",
        "  #{amount.inspect}.#{amount.class.name}"
      )  unless ([Integer, Float].include? amount.class)
      @scale[axis] += amount  if (@scale.key? axis)
    end

    # Set the layer rotation.
    # Pass an <tt>angle</tt> as an Integer or Float.
    def set_rotation angle
      error(
        "Passed argument `angle' needs to be an Integer or Float, but got",
        "  #{angle.inspect}.#{angle.class.name}"
      )  unless ([Integer, Float].include? angle.class)
      @angle = angle
      handle_angle_overflow
    end

    # Increase (or decrease) the layer rotation.
    # Pass an <tt>angle</tt> as an Integer or Float.
    def increase_rotation angle
      error(
        "Passed argument `angle' needs to be an Integer or Float, but got",
        "  #{angle.inspect}.#{angle.class.name}"
      )  unless ([Integer, Float].include? angle.class)
      @angle += angle
      handle_angle_overflow
    end

    # Call this every frame.
    # This updates all its <tt>@children</tt>,
    # if they have an #update method.
    def update
      call_method_on_children :update
    end

    # Call this every frame.
    # This draws all its <tt>@children</tt>,
    # if they have a #draw method.
    def draw
      #scale = get_scale
      Gosu.translate(*get_corner(:left, :top).get_position.values) do
        Gosu.scale(@scale[:x], @scale[:y]) do
          Gosu.rotate(@angle, *get_center.values) do
            call_method_on_children :draw
          end
        end
      end
      draw_debug
    end

    private

      def draw_debug
        # Top
        Gosu.draw_line(
          *get_corner(:left, :top).values,  0xff_ff0000,
          *get_corner(:right, :top).values, 0xff_ff0000
        )
        # Right
        Gosu.draw_line(
          *get_corner(:right, :top).values,    0xff_ff0000,
          *get_corner(:right, :bottom).values, 0xff_ff0000,
        )
        # Bottom
        Gosu.draw_line(
          *get_corner(:right, :bottom).values, 0xff_ff0000,
          *get_corner(:left, :bottom).values,  0xff_ff0000,
        )
        # Left
        Gosu.draw_line(
          *get_corner(:left, :bottom).values, 0xff_ff0000,
          *get_corner(:left, :top).values,    0xff_ff0000,
        )
      end

      def set_mask_from mask
        if    (mask.is_a?(Mask))
          mask.assign_to self
        elsif (mask.is_a?(Hash))
          Mask.new(
            mask.merge(
              assign_to: self
            )
          )
        else
          error "Cannot set Mask as #{mask.inspect}:#{mask.class.name} for Layer."
        end
      end

      def call_method_on_children method_name
        get_children.each do |child|
          child.method(method_name).call  if (child.methods.include? method_name)
        end
      end

      def handle_angle_overflow
        return  if ((0 ... 360).include? @angle)
        @angle -= 360  if (@angle >= 360)
        @angle += 360  if (@angle <  0)
        handle_angle_overflow
      end
  end
end

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

    def increase_scale axis, amount
      @scale[axis] += amount  if (@scale.key? axis)
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
          call_method_on_children :draw
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

      def get_scale
        window = Window.get_window
        return {
          x: (get_size(:width).to_f  / window.get_size(:width).to_f),
          y: (get_size(:height).to_f / window.get_size(:height).to_f),
        }
      end
  end
end

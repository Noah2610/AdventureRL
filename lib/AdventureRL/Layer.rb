module AdventureRL
  # This class is supposed to be a sort of container
  # for instances which have Mask s assigned to them.
  # It can manipulate any drawing operations, which will
  # effect all Mask s contained. See Gosu methods.
  # Layer also has a Mask.
  class Layer
    include Helpers::Error

    # Default settings.
    # <tt>settings</tt> passed to #new take precedence.
    DEFAULT_SETTINGS = Settings.new(
      mask: {
        position: {
          x: 0,
          y: 0
        },
        size: {
          width:  360,
          height: 360
        },
        origin: {
          x: :left,
          y: :top
        }
      },
      scale: {
        x: 1,
        y: 1
      },
      rotation: 0
    )

    # Initialize Layer with a <tt>settings</tt> Hash.
    # See DEFAULT_SETTINGS for valid keys.
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      set_mask_from @settings.get(:mask)
      @scale    = @settings.get :scale
      @rotation = @settings.get :rotation
      @children = []
    end

    # Add any object to this Layer.
    def add object
      @children << object
      object.set_layer self  if (object.methods.include?(:set_layer) || object_mask_has_method?(object, :set_layer))
    end
    alias_method :<<, :add

    # Returns all its children objects.
    def get_children
      return @children
    end

    # Returns the current scale.
    # <tt>target</tt> can be either <tt>:x</tt>, <tt>:y</tt>, or <tt>:all</tt>.
    def get_scale target = :all
      return @scale[target]  if (@scale.key? target)
      return @scale          if (target == :all)
      return nil
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

    # Returns the current rotation.
    def get_rotation
      return @rotation
    end

    # Set the layer rotation.
    # Pass an <tt>angle</tt> as an Integer or Float.
    def set_rotation angle
      error(
        "Passed argument `angle' needs to be an Integer or Float, but got",
        "  #{angle.inspect}.#{angle.class.name}"
      )  unless ([Integer, Float].include? angle.class)
      @rotation = angle
      handle_rotation_overflow
    end

    # Increase (or decrease) the layer rotation.
    # Pass an <tt>angle</tt> as an Integer or Float.
    def increase_rotation angle
      error(
        "Passed argument `angle' needs to be an Integer or Float, but got",
        "  #{angle.inspect}.#{angle.class.name}"
      )  unless ([Integer, Float].include? angle.class)
      @rotation += angle
      handle_rotation_overflow
    end

    # This method is called if any button is pressed down.
    # The passed argument <tt>btnid</tt> is the numerical id of the button.
    # See Window#button_down and Gosu::Window#button_down methods.
    def button_down btnid
      call_method_on_children :button_down, btnid
    end

    # This method is called if any button is released.
    # The passed argument <tt>btnid</tt> is the numerical id of the button.
    # See Window#button_up and Gosu::Window#button_up methods.
    def button_up btnid
      call_method_on_children :button_up, btnid
    end

    # Returns a new Point with this Layers real window position.
    def get_real_point
      return get_corner :left, :top  unless (has_layer?)
      real_point = get_layer.get_real_point
      return Point.new(
        (real_point.x + get_side(:left)),
        (real_point.y + get_side(:top))
      )
    end

    # Call this every frame.
    # This updates all its <tt>@children</tt>,
    # if they have an #update method.
    def update
      call_method_on_children :update
      call_method_on_children :update_mask
    end

    # Call this every frame.
    # This draws all its <tt>@children</tt>,
    # if they have a #draw method.
    def draw
      Gosu.scale(@scale[:x], @scale[:y], x, y) do
        Gosu.rotate(@rotation, *get_center.values) do
          Gosu.translate(*get_corner(:left, :top).get_position.values) do
            call_method_on_children :draw
          end
          #draw_debug  # TODO: Clean up
        end
      end
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

      def call_method_on_children method_name, *args
        get_children.each do |child|
          meth = nil
          if    (child.methods.include?(method_name))
            meth = child.method(method_name)
          elsif (object_mask_has_method?(child, method_name))
            meth = child.get_mask.method(method_name)
          end
          meth.call(*args)  if (meth)
        end
      end

      def object_mask_has_method? object, method_name
        return (
          object_has_mask?(object) &&
          object.get_mask.methods.include?(method_name)
        )
      end

      def object_has_mask? object
        begin
          object.has_mask?
        rescue NoMethodError
          return false
        end
        return true
      end

      def handle_rotation_overflow
        return  if ((0 ... 360).include? @rotation)
        @rotation -= 360  if (@rotation >= 360)
        @rotation += 360  if (@rotation <  0)
        handle_rotation_overflow
      end
  end
end

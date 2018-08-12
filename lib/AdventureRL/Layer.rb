module AdventureRL
  # This class is supposed to be a sort of container
  # for instances which have Mask s assigned to them.
  # It can manipulate any drawing operations, which will
  # effect all Mask s contained. See Gosu methods.
  # Layer also has a Mask.
  class Layer < Mask
    include Helpers::Error
    include Modifiers::Inventory

    # Default settings.
    # <tt>settings</tt> passed to #new take precedence.
    DEFAULT_SETTINGS = Settings.new(
      scale: {
        x: 1,
        y: 1
      },
      rotation: 0,
      has_solids_manager: false,
      solids_manager: {
        use_cache: false
      },
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
    )

    MASK_ID = :mask

    # Initialize Layer with a <tt>settings</tt> Hash.
    # See DEFAULT_SETTINGS for valid keys.
    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings #.get.reject { |key,val| next key == :assign_to }
      @scale              = @settings.get :scale
      @rotation           = @settings.get :rotation
      @has_solids_manager = !!@settings.get(:has_solids_manager)
      @solids_manager     = SolidsManager.new  if (has_solids_manager?)
    end

    # Add any object to this Layer.
    # Pass an optional <tt>id</tt>, which can be used to
    # access or remove the object afterwards.
    def add_object object, id = nil
      id   = MASK_ID  if (id.nil? && object.is_a?(Mask))
      id ||= DEFAULT_INVENTORY_ID
      super object, id
      object.set_layer self  if (object.methods.include?(:set_layer) || object_mask_has_method?(object, :set_layer))
    end
    alias_method :add_item, :add_object
    alias_method :add,      :add_object
    alias_method :<<,       :add_object

    # Returns the current scale.
    # <tt>target</tt> can be either <tt>:x</tt>, <tt>:y</tt>, or <tt>:all</tt>.
    def get_scale target = :all
      return @scale[target]  if (@scale.key? target)
      return @scale          if (target == :all)
      return nil
    end

    # Returns the real scale of this Layer.
    # That is, this Layer's scale multiplied by all
    # parent Layer's scales.
    def get_real_scale target = :all
      return get_scale target  unless (has_layer?)
      return get_layer.get_real_scale(target) * get_scale(target)  if (@scale.key? target)
      return {
        x: (get_layer.get_real_scale(:x) * get_scale(:x)),
        y: (get_layer.get_real_scale(:y) * get_scale(:y))
      }  if (target == :all)
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

    # Returns a new Point with this Layers real window position.
    def get_real_point
      pos_x = x * get_scale(:x)
      pos_y = y * get_scale(:y)
      return Point.new(pos_x, pos_y)  unless (has_layer?)
      real_point = get_layer.get_real_point
      return Point.new(
        (real_point.x + pos_x),
        (real_point.y + pos_y)
      )
    end

    # Returns <tt>true</tt> if this Layer has a SolidsManager.
    def has_solids_manager?
      return @has_solids_manager || (has_layer? ? get_layer.has_solids_manager? : false)
    end

    # Returns a SolidsManager, if it has one.
    def get_solids_manager
      return @solids_manager               if (@solids_manager)
      return get_layer.get_solids_manager  if (has_layer?)
      return nil
    end

    # Overwrite the method Point#move_by, so we can
    # also call #move_by on all Mask children.
    # We use a little hacky workaround, by moving all children back
    # the amount of incremental movement, then move this Layer forward,
    # and then move all the children Masks via #move_by.
    def move_by *args
      incremental_position = parse_position(*args)
      incremental_position[:x] ||= 0
      incremental_position[:y] ||= 0
      objects = get_objects.select do |object|
        next object.is_a?(Mask)
      end
      # Move all children Masks back via #set_position.
      objects.each do |mask|
        mask.set_position(
          (mask.x - incremental_position[:x]),
          (mask.y - incremental_position[:y])
        )
      end
      super  # Move Layer forward
      # Move all children Masks forward via #move_by.
      objects.each do |mask|
        mask.move_by incremental_position
      end
    end

    # Call this every frame.
    # This updates all its inventory objects (its children),
    # if they have an #update method.
    def update
      call_method_on_children :update
      get_solids_manager.update  if (has_solids_manager?)
    end

    # Call this every frame.
    # This draws all its inventory objects (its children),
    # if they have a #draw method.
    def draw
      Gosu.scale(@scale[:x], @scale[:y], x, y) do
        Gosu.rotate(@rotation, *get_center.values) do
          Gosu.translate(*get_corner(:left, :top).get_position.values) do
            call_method_on_children :draw
          end
          draw_debug  # TODO: Clean up
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

      def call_method_on_children method_name, *args
        get_objects.each do |child|
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

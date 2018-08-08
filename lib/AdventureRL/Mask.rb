module AdventureRL
  # The Mask is basically a bounding box or rectangle.
  # It has a position (Point) and a size.
  class Mask < Point
    include Helpers::MethodHelper

    # This array will be filled with any created Masks.
    # Just so they won't get garbage collected
    # <em>(not sure how garbage collection works)</em>.
    MASKS = []

    # Default settings for Mask.
    # Are superseded by settings passed to <tt>#initialize</tt>.
    DEFAULT_SETTINGS = Settings.new({
      position: {
        x: 0,
        y: 0
      },
      size: {
        width:  64,
        height: 64
      },
      origin: {
        x: :left,
        y: :top
      },
      assign_to: nil
    })

    # Pass settings Hash or <tt>AdventureRL::Settings</tt> as argument.
    # Supersedes <tt>DEFAULT_SETTINGS</tt>.
    def initialize settings_arg = {}
      MASKS << self
      settings = DEFAULT_SETTINGS.merge settings_arg
      super *settings.get(:position).values
      @size             = settings.get(:size)
      @origin           = settings.get(:origin)
      @assigned_to    = []
      assign_to settings.get(:assign_to)  if (settings.get(:assign_to))
      @layer            = nil
      call_setup_method settings_arg
    end

    # Assign this Mask to an instance.
    # This will make all Mask methods available as
    # a fallback on the instance itself.
    # This also gives the possibility to define event methods
    # on the <tt>object</tt>.
    def assign_to object
      Helpers::PipeMethods.pipe_methods_from object, to: self
      @assigned_to << object
    end

    # Returns all objects this Mask was assigned to.
    def get_assigned
      return @assigned_to
    end

    # Returns true if the Mask has been
    # assigned to the passed <tt>object</tt>.
    def assigned_to? object
      return @assigned_to.include? object
    end

    # Returns self.
    # Used to get an instance's mask when it has been assigned to it.
    def get_mask
      return self
    end

    # Returns <tt>true</tt>.
    # Used to verify if an instance has a Mask assigned to it.
    def has_mask?
      return true
    end

    # Returns the size of the Mask.
    # Can pass an optional <tt>target</tt> argument,
    # which can be either an axis (<tt>:width</tt> or <tt>:height</tt>),
    # or <tt>:all</tt>, which returns a Hash with both values.
    def get_size target = :all
      target = target.to_sym
      return @size          if (target == :all)
      return @size[target]  if (@size.keys.include?(target))
      return nil
    end

    # Returns the set origin.
    # Can pass an optional <tt>target</tt> argument,
    # which can be either an axis (<tt>:x</tt> or <tt>:y</tt>),
    # or <tt>:all</tt>, which returns a Hash with both values.
    def get_origin target = :all
      target = target.to_sym
      return @origin          if (target == :all)
      return @origin[target]  if (@origin.keys.include?(target))
      return nil
    end

    # Returns the position Integer of a specific side.
    # Takes one mandatory argument, <tt>side</tt>,
    # which can be one of the following:
    # <tt>:left</tt> or <tt>:right</tt>::
    #   Returns the x position of the left or right side/border, respectively.
    # <tt>:top</tt> or <tt>:bottom</tt>::
    #   Returns the y position of the top or bottom side/border, respectively.
    def get_side side
      side = side.to_sym
      case side
      when :left
        return get_side_left
      when :right
        return get_side_right
      when :top
        return get_side_top
      when :bottom
        return get_side_bottom
      else
        return nil
      end
    end

    # Returns the real window position of <tt>side</tt>.
    # See #get_side for usage.
    def get_real_side side
      axis = :x  if ([:left, :right].include? side)
      axis = :y  if ([:top, :bottom].include? side)
      side_pos  = get_side(side) * get_scale(axis)
      return side_pos  unless (has_layer?)
      case side
      when :left, :right
        return get_layer.get_real_side(:left) + side_pos
      when :top, :bottom
        return get_layer.get_real_side(:top) + side_pos
      else
        return nil
      end
    end

    # Returns the positions of all four sides.
    def get_sides
      return {
        left:   get_side(:left),
        right:  get_side(:right),
        top:    get_side(:top),
        bottom: get_side(:bottom)
      }
    end

    # Returns the real window positions of all four sides.
    def get_real_sides
      return {
        left:   get_real_side(:left),
        right:  get_real_side(:right),
        top:    get_real_side(:top),
        bottom: get_real_side(:bottom)
      }
    end

    # Returns a Point with the position of a specific corner.
    # Takes two mandatory arguments:
    # <tt>side_x</tt>:: Either <tt>:left</tt> or <tt>:right</tt>.
    # <tt>side_y</tt>:: Either <tt>:top</tt> or <tt>:bottom</tt>.
    def get_corner side_x, side_y
      side_x = side_x.to_sym
      side_y = side_y.to_sym
      return Point.new(
        get_side(side_x),
        get_side(side_y)
      )  unless ([side_x, side_y].include? :center)
      if    (side_x == side_y)
        center = get_center.values
        return Point.new(*center)
      elsif (side_x == :center)
        return Point.new(
          get_center(:x),
          get_side(side_y)
        )
      elsif (side_y == :center)
        return Point.new(
          get_side(side_x),
          get_center(:y)
        )
      end
      return nil
    end

    # Returns the real window position of the corner.
    # See #get_corner for usage.
    def get_real_corner side_x, side_y
      side_x = side_x.to_sym
      side_y = side_y.to_sym
      return Point.new(
        get_real_side(side_x),
        get_real_side(side_y)
      )  unless ([side_x, side_y].include? :center)
      if    (side_x == side_y)
        center = get_real_center.values
        return Point.new(*center)
      elsif (side_x == :center)
        return Point.new(
          get_real_center(:x),
          get_real_side(side_y)
        )
      elsif (side_y == :center)
        return Point.new(
          get_real_side(side_x),
          get_real_center(:y)
        )
      end
      return nil
    end

    # Returns the center Point of the Mask.
    # An optional <tt>target</tt> argument can be passed,
    # which can either be an axis (<tt>:x</tt> or <tt>:y</tt>),
    # or <tt>:all</tt>, which returns a Hash with both values.
    def get_center target = :all
      target = target.to_sym
      return Point.new(
        get_center_x,
        get_center_y
      )  if (target == :all)
      return method("get_center_#{target.to_s}".to_sym).call  if (get_point.keys.include? target)
      return nil
    end

    # Returns the real window position of this center.
    # See #get_center for usage.
    def get_real_center target = :all
      scale = get_scale
      side = :left  if (target == :x)
      side = :top   if (target == :y)
      return Point.new(
        (get_real_side(:left) + (get_center_x * scale[:x])),
        (get_real_side(:top)  + (get_center_y * scale[:y]))
      )  if (target == :all)
      return (
        get_real_side(side) + (method("get_center_#{target.to_s}".to_sym).call * scale[target])
      )  if (get_point.keys.include? target)
      return nil
    end

    # Returns true if this Mask collides with <tt>other</tt> ...
    # - Mask,
    # - Point,
    # - or Hash with keys <tt>:x</tt> and <tt>:y</tt>.
    def collides_with? other
      return collides_with_mask?  other  if (other.has_mask?  rescue false)
      return collides_with_point? other  if (other.has_point? rescue false)
      return collides_with_hash?  other  if (other.is_a?(Hash))
    end

    # Returns true if this Mask collides with <tt>other</tt> Mask.
    def collides_with_mask? mask, checked = false
      this_sides  = get_real_sides
      other_sides = mask.get_real_sides
      return (
        (
          (
            other_sides[:left] >= this_sides[:left] &&
            other_sides[:left] <= this_sides[:right]
          ) || (
            other_sides[:right] >= this_sides[:left] &&
            other_sides[:right] <= this_sides[:right]
          )
        ) && (
          (
            other_sides[:top] >= this_sides[:top] &&
            other_sides[:top] <= this_sides[:bottom]
          ) || (
            other_sides[:bottom] >= this_sides[:top] &&
            other_sides[:bottom] <= this_sides[:bottom]
          )
        )
      ) || (!checked && mask.collides_with_mask?(self, true))
    end

    # Returns true if this Mask collides with <tt>other</tt> Point.
    def collides_with_point? point
      real_point = point.get_real_point
      real_sides = get_real_sides
      return (
        real_point.x >= real_sides[:left]  &&
        real_point.x <= real_sides[:right] &&
        real_point.y >= real_sides[:top]   &&
        real_point.y <= real_sides[:bottom]
      )
    end

    # Returns true if this Mask collides with <tt>other</tt> Hash.
    def collides_with_hash? hash
      if (hash.keys.include_all?(:x, :y))
        point = Point.new hash[:x], hash[:y]
        return collides_with_point? point
      end
      return nil
    end

    # Set the parent Layer.
    def set_layer layer
      error(
        "Passed argument `layer' must be an instance of `Layer', but got",
        "`#{layer.inspect}:#{layer.class.name}'."
      )  unless (layer.is_a? Layer)
      @layer = layer
      #get_point.set_layer @layer
    end

    # Returns the parent Layer.
    def get_layer
      return @layer
    end

    # Returns true if this Mask has a parent Layer.
    def has_layer?
      return !!@layer
    end

    private

      def call_setup_method args
        return  unless (method_exists?(:setup))
        if (method_takes_arguments?(:setup))
          setup args
        else
          setup
        end
      end

      def call_method_on_assigned method_name, *args
        get_assigned.each do |assigned_to|
          meth = nil
          meth = assigned_to.method(method_name)  if (assigned_to.methods.include?(method_name))
          meth.call(*args)                        if (meth)
        end
      end

      # Returns this Masks Layer scale, if it has one.
      def get_scale target = :all
        return get_layer.get_real_scale target  if (has_layer?)
        scale = { x: 1.0, y: 1.0 }
        return scale[target]  if (scale.key? target)
        return scale          if (target == :all)
        return nil
      end

      def get_side_left
        case get_origin(:x)
        when :left
          return get_position(:x)
        when :right
          return get_position(:x) - get_size(:width)
        when :center
          return get_position(:x) - (get_size(:width) * 0.5)
        else
          return nil
        end
      end

      def get_side_right
        case get_origin(:x)
        when :left
          return get_position(:x) + get_size(:width)
        when :right
          return get_position(:x)
        when :center
          return get_position(:x) + (get_size(:width) * 0.5)
        else
          return nil
        end
      end

      def get_side_top
        case get_origin(:y)
        when :top
          return get_position(:y)
        when :bottom
          return get_position(:y) - get_size(:height)
        when :center
          return get_position(:y) - (get_size(:height) * 0.5)
        else
          return nil
        end
      end

      def get_side_bottom
        case get_origin(:y)
        when :top
          return get_position(:y) + get_size(:height)
        when :bottom
          return get_position(:y)
        when :center
          return get_position(:y) + (get_size(:height) * 0.5)
        else
          return nil
        end
      end

      def get_center_x
        case get_origin(:x)
        when :left
          return get_position(:x) + (get_size(:width) * 0.5)
        when :right
          return get_position(:x) - (get_size(:width) * 0.5)
        when :center
          return get_position(:x)
        end
      end

      def get_center_y
        case get_origin(:y)
        when :top
          return get_position(:y) + (get_size(:height) * 0.5)
        when :bottom
          return get_position(:y) - (get_size(:height) * 0.5)
        when :center
          return get_position(:y)
        end
      end
  end
end

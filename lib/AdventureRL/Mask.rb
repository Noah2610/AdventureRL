module AdventureRL
  # The Mask is basically a bounding box or rectangle.
  # It has a position (Point) and a size.
  class Mask
    MASKS = []

    # Default settings for Mask.
    # Are superseded by settings passed to <tt>#initialize</tt>.
    DEFAULT_SETTINGS = Settings.new({
      #position: Point.new(0, 0),
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
      assign_to:    nil,
      mouse_events: false
    })
    # This class variable will be filled with Mask s,
    # which are passed <tt>mouse_events: true</tt> on #new.
    # They will be updated by Window every so often,
    # to check for mouse collisions, and trigger mouse event methods, such as:
    # #on_mouse_down::  Is called when any mouse button is pressed down on the Mask.
    # #on_mouse_up::    Is called when any mouse button is released on the Mask.
    # #on_mouse_press:: Is continuously called if any mouse button is held down on the Mask.
    # These methods should be defined on the instance which has a Mask assigned.
    @@masks_for_mouse_events = []

    class << self
      # Returns all Masks, which have <tt>mouse_events</tt> enabled.
      def get_masks_for_mouse_events
        return @@masks_for_mouse_events
      end
    end

    # Pass settings Hash or <tt>AdventureRL::Settings</tt> as argument.
    # Supersedes <tt>DEFAULT_SETTINGS</tt>.
    def initialize settings_arg = {}
      MASKS << self
      settings = DEFAULT_SETTINGS.merge settings_arg
      set_position_from settings.get(:position)
      @size             = settings.get(:size)
      @origin           = settings.get(:origin)
      @has_mouse_events = settings.get(:mouse_events)
      @assigned_to      = []
      assign_to settings.get(:assign_to)  if (settings.get(:assign_to))
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

    # Returns the position Integer of a specifi side.
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

    # Returns the positions of all four sides.
    def get_sides
      return {
        left:   get_side(:left),
        right:  get_side(:right),
        top:    get_side(:top),
        bottom: get_side(:bottom)
      }
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
    end

    # Returns true if this Mask collides with <tt>other</tt> ...
    # - Mask,
    # - Point,
    # - or Hash with keys <tt>:x</tt> and <tt>:y</tt>.
    def collides_with? other
      return collides_with_mask?  other  if (defined? other.get_mask)
      return collides_with_point? other  if (defined? other.get_point)
      return collides_with_hash?  other  if (other.is_a?(Hash))
    end

    # Returns true if this Mask collides with <tt>other</tt> Point.
    def collides_with_point? point
      return (
        point.x >= get_side(:left)  &&
        point.x <  get_side(:right) &&
        point.y >= get_side(:top)   &&
        point.y <  get_side(:bottom)
      )
    end

    # Returns true if this Mask collides with <tt>other</tt> Mask.
    def collides_with_mask? mask
      this_sides  = get_sides
      other_sides = mask.get_sides
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
            other_sides[:top] >= this_sides[:top]  &&
            other_sides[:top] <= this_sides[:bottom]
          ) || (
            other_sides[:bottom] >= this_sides[:top]  &&
            other_sides[:bottom] <= this_sides[:bottom]
          )
        )
      )
    end

    # Returns true if this Mask collides with <tt>other</tt> Hash.
    def collides_with_hash? other_hash
      if (hash.keys.include_all?(:x, :y))
        other_point = Point.new hash[:x], hash[:y]
        return collides_with_point? other_point
      end
      return nil
    end

    # Returns true if this Mask can have mouse events.
    def has_mouse_events?
      return @has_mouse_events
    end

    private

      def set_position_from position
        if    (position.is_a?(Point))
          position.assign_to self
        elsif (position.is_a?(Hash))
          Point.new(
            position[:x],
            position[:y],
            assign_to: self
          )
        else
          Helpers::Error.error "Cannot set Point as #{position.to_s}:#{position.class.name} for Mask."
        end
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

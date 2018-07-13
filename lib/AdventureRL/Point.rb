module AdventureRL
  class Point
    # This array will be filled with any created Points.
    # Just so they won't get garbage collected
    # <em>(not sure how garbage collection works)</em>.
    POINTS = []

    def initialize x, y, args = {}
      POINTS << self
      @position = {
        x: x,
        y: y
      }
      @assigned_to = []
      assign_to args[:assign_to]  if (args[:assign_to])
      @layer      = nil
      @real_point = nil
    end

    def assign_to object
      Helpers::PipeMethods.pipe_methods_from object, to: self
      @assigned_to << object
    end

    def get_point
      return self
    end

    def has_point?
      return true
    end

    def x
      return get_position :x
    end

    def y
      return get_position :y
    end

    def get_position target = :all
      target = target.to_sym
      return @position          if (target == :all)
      return @position[target]  if (@position.keys.include?(target))
      return nil
    end

    def set_position *args
      @real_point = nil
      case args.size
      when 2
        @position[:x] = args[0]
        @position[:y] = args[1]
      when 1
        Helpers::Error.error(
          "Ambiguous argument `#{args[0]}' for Point#set_position"
        )  unless (args[0].is_a?(Hash))
        Helpers::Error.error(
          'Hash must include either :x, :y, or both keys for Point#set_position'
        )  unless (args[0].keys.include_any?(:x, :y))
        @position[:x] = args[0][:x]  if (args[0][:x])
        @position[:y] = args[0][:y]  if (args[0][:y])
      else
        Helpers::Error.error(
          'Invalid amount of arguments for Point#set_position.',
          'Pass either two arguments representing the x and y axes, respectively, or',
          'pass a single hash with the keys :x and :y with their respective axes values.'
        )
      end
      return get_position
    end
    alias_method :move_to, :set_position

    def move_by *args
      @real_point = nil
      case args.size
      when 2
        @position[:x] += args[0]
        @position[:y] += args[1]
      when 1
        Helpers::Error.error(
          "Ambiguous argument `#{args[0]}' for Point#move_by"
        )  unless (args[0].is_a?(Hash))
        Helpers::Error.error(
          'Hash must include either :x, :y, or both keys for Point#move_by'
        )  unless (args[0].keys.include_any?(:x, :y))
        @position[:x] += args[0][:x]  if (args[0][:x])
        @position[:y] += args[0][:y]  if (args[0][:y])
      else
        Helpers::Error.error(
          'Invalid amount of arguments for Point#move_by.',
          'Pass either two arguments representing the x and y axes, respectively, or',
          'pass a single hash with the keys :x and :y with their respective axes values.'
        )
      end
      return get_position
    end

    def collides_with? other
      return collides_with_mask?  other  if (defined? other.has_mask?)
      return collides_with_point? other  if (defined? other.has_point?)
      return collides_with_hash?  other  if (other.is_a?(Hash))
    end

    def collides_with_mask? mask
      return mask.collides_with_point? self
    end

    def collides_with_point? point
      return get_real_position == point.get_real_position
    end

    def collides_with_hash? hash
      if (hash.keys.include_all?(:x, :y))
        point = Point.new hash[:x], hash[:y]
        return collides_with_point? point
      end
      return nil
    end

    def keys
      sorted_keys = [:x, :y]
      return @position.keys.sort do |axis|
        next sorted_keys.index axis
      end
    end

    def values
      return @position.sort_by_keys(keys).values
    end

    # Set the parent Layer.
    def set_layer layer
      error(
        "Passed argument `layer' must be an instance of `Layer', but got",
        "`#{layer.inspect}:#{layer.class.name}'."
      )  unless (layer.is_a? Layer)
      @layer = layer
    end

    # Returns the parent Layer.
    def get_layer
      return @layer
    end

    # Returns true if this Point has a parent Layer.
    def has_layer?
      return !!@layer
    end

    # Returns a new Point with the real window position of this Point.
    def get_real_point
      return self         unless (has_layer?)
      return @real_point  if (@real_point)
      real_point  = get_layer.get_real_point
      @real_point = Point.new(
        (real_point.x + x),
        (real_point.y + y)
      )
      return @real_point
    end

    # Returns the real window position of this Point as a Hash.
    def get_real_position
      return get_real_point.get_position
    end
  end
end

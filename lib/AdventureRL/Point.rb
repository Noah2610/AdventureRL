module AdventureRL
  class Point
    def initialize x, y, args = {}
      @position = {
        x: x,
        y: y
      }
      assign_to args[:assign_to]  if (args[:assign_to])
    end

    def assign_to object
      Helpers::PipeMethods.pipe_methods_from object, to: self
    end

    def get_point
      return self
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
      return collides_with_point? other  if (other.is_a?(Point))
      return collides_with_mask?  other  if (other.is_a?(Mask) || other.is_a?(Rectangle))
      return collides_with_hash?  other  if (other.is_a?(Hash))
    end

    def collides_with_point? point
      return get_position == point.get_position
    end

    def collides_with_mask? mask
      return mask.collides_with_point? self
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
  end
end

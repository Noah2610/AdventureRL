module AdventureRL
  class Point
    def initialize x, y
      @position = {
        x: x,
        y: y
      }
    end

    def get_position target = :all
      target = target.to_sym
      return @position          if (target == :all)
      return @position[target]  if (@position.keys.include?(target))
      return nil
    end
    alias_method :get_pos,  :get_position
    alias_method :position, :get_position
    alias_method :pos,      :get_position

    def x
      return get_position :x
    end

    def y
      return get_position :y
    end

    def collides_with? other
      return collides_with_point? other  if (other.is_a?(Point))
      return collides_with_mask?  other  if (other.is_a?(Mask))
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

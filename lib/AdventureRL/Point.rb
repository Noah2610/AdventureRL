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

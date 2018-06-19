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
      if    (target == :all)
        return @position
      elsif (@position.keys.include?(target))
        return @position[target]
      else
        return nil
      end
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
  end
end

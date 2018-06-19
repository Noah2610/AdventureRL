module AdventureRL
  class Mask
    DEFAULT_ARGS = {
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
      }
    }
    def initialize args = {}
      options   = DEFAULT_ARGS.merge args
      @position = get_position_from_arg options[:position]
      @size     = options[:size]
      @origin   = options[:origin]
    end

    private

    def get_position_from_arg position_arg
      return position_arg  if (position_arg.is_a? Point)
      return Point.new(
        position_arg[:x],
        position_arg[:y]
      )                    if (position_arg.is_a? Hash)
      return nil
    end
  end
end

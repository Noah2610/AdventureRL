module AdventureRL
  class Quadtree < Mask
    include Helpers::MethodHelper

    window = Window.get_window
    DEFAULT_SETTINGS = Settings.new(
      objects:     [],
      max_objects: 1,
      position: (window ? window.get_position : DEFAULT_SETTINGS.get(:window, :position) || {
        x: 0,
        y: 0
      }),
      size:     (window ? window.get_size     : DEFAULT_SETTINGS.get(:window, :size) || {
        width:  960,
        height: 540
      }),
      origin:   (window ? window.get_origin   : DEFAULT_SETTINGS.get(:window, :origin) || {
        x: :left,
        y: :top
      }),
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings
      @objects     = [@settings.get(:objects)].flatten.compact
      @max_objects = @settings.get :max_objects
      @quadtrees   = {
        top_left:     nil,
        top_right:    nil,
        bottom_left:  nil,
        bottom_right: nil
      }
    end

    # Add the given Mask <tt>object</tt>(s) into the Quadtree,
    # and split into smaller quadtrees if necessary.
    def add_object object
      objects = [object].flatten
      objects.each do |obj|
        validate_object_has_mask obj
        add_object_to_quadtree obj
      end
    end
    alias_method :add, :add_object

    def add_object_to_quadtree object
      return false  unless (collides_with? object)

      if (@objects.size < @max_objects)
        @objects << object
        return true
      end

      create_quadtrees  unless (has_quadtrees?)

      return @quadtrees.values.map do |quadtree|
        next quadtree.add_object_to_quadtree(object)
      end .any?
    end

    # Returns all objects, that collide with <tt>object</tt>.
    def get_colliding_objects object
      validate_object_has_mask object
      return query_for(object)
    end

    def query_for object
      colliding_objects = []
      return colliding_objects  unless (collides_with? object)
      colliding_objects.concat(@objects.select do |obj|
        next obj.collides_with?(object)  unless (obj == object)
        next false
      end)
      @quadtrees.values.each do |quadtree|
        colliding_objects.concat quadtree.query_for(object)
      end  if (has_quadtrees?)
      return colliding_objects
    end

    # Reset this and all child Quadtrees.
    # Remove all added Mask objects.
    def reset
      @objects.clear
      @quadtrees.values.each &:reset  if (has_quadtrees?)
    end

    # TODO
    def draw
      # Top
      Gosu.draw_line(
        *get_real_corner(:left, :top).values,  0xff_ff0000,
        *get_real_corner(:right, :top).values, 0xff_ff0000,
        100
      )
      # Right
      Gosu.draw_line(
        *get_real_corner(:right, :top).values,    0xff_ff0000,
        *get_real_corner(:right, :bottom).values, 0xff_ff0000,
        100
      )
      # Bottom
      Gosu.draw_line(
        *get_real_corner(:right, :bottom).values, 0xff_ff0000,
        *get_real_corner(:left, :bottom).values,  0xff_ff0000,
        100
      )
      # Left
      Gosu.draw_line(
        *get_real_corner(:left, :bottom).values, 0xff_ff0000,
        *get_real_corner(:left, :top).values,    0xff_ff0000,
        100
      )
      @quadtrees.values.each &:draw  if (has_quadtrees?)
    end

    private

      def validate_object_has_mask object
        object.get_mask  rescue error(
          "Expected an instance of Mask or an object that has a Mask, but got",
          "`#{object.inspect}:#{object.class.name}'."
        )
      end

      # Returns <tt>true</tt> if this Quadtree has already been split
      # and has children Quadtrees.
      def has_quadtrees?
        return @quadtrees.values.all?
      end

      def create_quadtrees
        @quadtrees = @quadtrees.keys.map do |corner|
          new_quadtree = get_split_quadtree_for_corner corner
          next [corner, new_quadtree]  if (new_quadtree)
          next nil
        end .compact.to_h
        #move_objects_to_quadtrees  if (@objects.any?)  # NOTE: Doing this will break stuff.
      end

      def get_split_quadtree_for_corner corner
        method_name = "get_split_quadtree_#{corner.to_s}".to_sym
        error(
          "Method `#{method_name.to_s}' doesn't exist for `#{self.inspect}:#{self.class}'."
        )  unless (method_exists? method_name)
        return method(method_name).call
      end

      def get_split_quadtree_top_left
        return Quadtree.new(Settings.new(
          position:    get_position,
          size:        get_size.map do |side, size|
            next [side, (size.to_f * 0.5).round]
          end .to_h,
          origin:      get_origin,
          max_objects: @max_objects
        ))
      end

      def get_split_quadtree_top_right
        return Quadtree.new(Settings.new(
          position:    get_position.map do |axis, pos|
            next [axis, pos + (get_size(:width).to_f * 0.5).round]  if (axis == :x)
            next [axis, pos]
          end .to_h,
          size:        get_size.map do |side, size|
            next [side, (size.to_f * 0.5).round]
          end .to_h,
          origin:      get_origin,
          max_objects: @max_objects
        ))
      end

      def get_split_quadtree_bottom_left
        return Quadtree.new(Settings.new(
          position:    get_position.map do |axis, pos|
            next [axis, pos + (get_size(:height).to_f * 0.5).round]  if (axis == :y)
            next [axis, pos]
          end .to_h,
          size:        get_size.map do |side, size|
            next [side, (size.to_f * 0.5).round]
          end .to_h,
          origin:      get_origin,
          max_objects: @max_objects
        ))
      end

      def get_split_quadtree_bottom_right
        return Quadtree.new(Settings.new(
          position:    get_position.map do |axis, pos|
            next [axis, pos + (get_size(:width).to_f  * 0.5).round]  if (axis == :x)
            next [axis, pos + (get_size(:height).to_f * 0.5).round]  if (axis == :y)
          end .to_h,
          size:        get_size.map do |side, size|
            next [side, (size.to_f * 0.5).round]
          end .to_h,
          origin:      get_origin,
          max_objects: @max_objects
        ))
      end

      # NOTE: Shouldn't be used, breaks stuff currently.
      #       Life is easier without this method.
      def move_objects_to_quadtrees
        return  if (@objects.empty?)
        @objects.each do |object|
          @quadtrees.values.detect do |quadtree|
            next quadtree.add_object_to_quadtree(object)
          end
        end
        @objects.clear
      end
  end
end

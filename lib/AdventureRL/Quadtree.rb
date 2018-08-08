module AdventureRL
  class Quadtree < Mask
    include Helpers::MethodHelper

    DEFAULT_SETTINGS = Settings.new(
      max_objects: 1,
      parent:      nil,
      position: {
        x: 0,
        y: 0
      },
      size: {
        width:  960,
        height: 540
      },
      origin: {
        x: :left,
        y: :top
      }
    )

    def self.get_default_settings
      window = Window.get_window
      return Settings.new(
        position: (window ? window.get_position : DEFAULT_SETTINGS.get(:window, :position) || DEFAULT_SETTINGS[:position]),
        size:     (window ? window.get_size     : DEFAULT_SETTINGS.get(:window, :size)     || DEFAULT_SETTINGS[:size]),
        origin:   (window ? window.get_origin   : DEFAULT_SETTINGS.get(:window, :origin)   || DEFAULT_SETTINGS[:origin]),
      )
    end

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge(Quadtree.get_default_settings).merge(settings)
      super @settings
      @max_objects     = @settings.get :max_objects
      @parent_quadtree = @settings.get :parent
      @quadtrees = {
        top_left:     nil,
        top_right:    nil,
        bottom_left:  nil,
        bottom_right: nil
      }
      @objects = []
      add_object [@settings.get(:objects)].flatten.compact
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
      return false  if     (@objects.include? object)

      if (@objects.size < @max_objects)
        @objects << object
        return true
      end

      split_quadtrees  unless (has_quadtrees?)

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

      # TODO
      @queried = true

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
    # (Recalculate in which Quadtree each object is supposed to be.)
    def reset
      # @objects.each do |object|
      #   reset_object object
      # end

      @objects.clear
      @quadtrees.values.each &:reset  if (has_quadtrees?)

      #@quadtrees = @quadtrees.map do |corner, quadtree|
      #  next [corner, nil]
      #end .to_h
    end

    # TODO
    def reset_object object
      return  if (add_object_to_quadtree object)
      @parent_quadtree.reset_object object  if (@parent_quadtree)
    end

    # TODO
    def draw
      Gosu.draw_rect(
        *get_real_corner(:left, :top).values,
        *get_size.values,
        (@queried ? 0xff_00ff00 : 0xff_ff0000),
        -1
      )
      @queried = false
      @quadtrees.values.each &:draw  if (has_quadtrees?)

      return
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

      def split_quadtrees
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
          parent:      self,
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
          parent:      self,
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
          parent:      self,
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
          parent:      self,
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

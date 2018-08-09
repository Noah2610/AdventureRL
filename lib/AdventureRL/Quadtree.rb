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

      return get_quadtrees.map do |quadtree|
        next quadtree.add_object_to_quadtree(object)
      end .any?
    end

    # Returns <tt>true</tt> if the given <tt>object</tt>
    # collides with any other object and <tt>false</tt> if not.
    def collides? object
      validate_object_has_mask object
      return collides_for?(object)
    end

    def collides_for? object
      return false  unless (collides_with? object)
      return (
        @objects.any? do |obj|
          next obj != object && obj.collides_with?(object)
        end ||
        get_quadtrees.any? do |quadtree|
          next quadtree.collides_for?(object)
        end
      )
    end

    # Returns all objects, that collide with <tt>object</tt>.
    def get_colliding_objects object
      validate_object_has_mask object
      return get_colliding_objects_for(object)
    end

    def get_colliding_objects_for object
      colliding_objects = []
      return colliding_objects  unless (collides_with? object)
      colliding_objects.concat(@objects.select do |obj|
        next obj != object && obj.collides_with?(object)
      end)
      get_quadtrees.each do |quadtree|
        colliding_objects.concat quadtree.get_colliding_objects_for(object)
      end
      return colliding_objects
    end

    # Reset this and all child Quadtrees.
    # Removes all stored objects.
    def reset
      @objects.clear
      get_quadtrees.each &:reset
    end

    # Remove and (try to) re-add the given <tt>object</tt>(s) (single or multiple).
    def reset_object object
      objects = [object].flatten
      objects.each do |obj|
        @objects.delete obj
        add_object_to_quadtree obj
      end
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
      get_quadtrees.each &:draw
    end

    private

      def validate_object_has_mask object
        object.get_mask  rescue error(
          "Expected an instance of Mask or an object that has a Mask, but got",
          "`#{object.inspect}:#{object.class.name}'."
        )
      end

      # Returns all the children Quadtrees.
      def get_quadtrees
        return @quadtrees.values.compact
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
          get_quadtrees.detect do |quadtree|
            next quadtree.add_object_to_quadtree(object)
          end
        end
        @objects.clear
      end
  end
end

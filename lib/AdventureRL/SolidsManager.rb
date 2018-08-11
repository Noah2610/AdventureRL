module AdventureRL
  class SolidsManager
    DEFAULT_SOLID_TAG = :default

    def initialize
      @quadtrees   = {}
      @objects     = {}
      @reset_queue = {}
      @cache       = {}
    end

    # Add one (or multiple) <tt>object</tt>(s)
    # with one (or multiple) <tt>solid_tag</tt>(s).
    def add_object object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      solid_tags.each do |tag|
        if (@objects[tag])
          @objects[tag].concat objects
        else
          @objects[tag] = objects
        end
        if (@quadtrees[tag])
          @quadtrees[tag].add_object objects
        else
          @quadtrees[tag] = Quadtree.new objects: objects
        end
      end
    end

    # Returns <tt>true</tt> if the given <tt>object</tt> (or multiple objects),
    # collide with any other objects with a mutual <tt>solid_tag</tt>.
    def collides? object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      return objects.any? do |obj|
        handle_collides_cache_for obj, solid_tags
        next @cache[obj][:collides?]
      end
    end

    # Returns all objects colliding with <tt>object</tt>(s).
    def get_colliding_objects object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      return objects.map do |obj|
        handle_colliding_objects_cache_for obj, solid_tags
        next @cache[obj][:colliding_objects]
      end .flatten
    end

    # Pass an <tt>object</tt> (or multiple), to queue it/them for
    # resetting next update.
    def reset_object object, solid_tag = DEFAULT_SOLID_TAG
      objects = [object].flatten
      solid_tags = [solid_tag].flatten
      solid_tags.each do |tag|
        @reset_queue[tag] ||= []
        @reset_queue[tag].concat objects
      end
    end

    # Resets for every object in <tt>@reset_queue</tt>.
    def reset
      @reset_queue.each do |solid_tag, objects|
        @quadtrees.map do |quadtree_tag, quadtree|
          next quadtree  if (solid_tag == quadtree_tag)
          next nil
        end .compact.each do |quadtree|
          quadtree.reset_object objects
        end
        @reset_queue[solid_tag] = []
      end
    end

    def reset_cache_for object
      @collides_cache.delete          object
      @colliding_objects_cache.delete object
    end

    # Called once every frame by Window.
    def update
      reset
    end

    private

      def get_quadtrees_for solid_tag = DEFAULT_SOLID_TAG
        solid_tags = [solid_tag].flatten
        return @quadtrees.map do |quadtree_tag, quadtree|
          next quadtree  if (solid_tags.include?(quadtree_tag))
          next nil
        end .compact
      end

      def handle_collides_cache_for object, solid_tags
        cached = @cache[object]
        update_collides_cache_for object, solid_tags  unless (
          cached                                     &&
          (cached[:position] == object.get_position) &&
          (cached[:size]     == object.get_size)
        )
      end

      def update_collides_cache_for object, solid_tags
        @cache[object] ||= {}
        @cache[object][:position]  = object.get_position.dup
        @cache[object][:size]      = object.get_size.dup
        @cache[object][:collides?] = get_quadtrees_for(solid_tags).any? do |quadtree|
          next quadtree.collides?(object)
        end
      end

      def handle_colliding_objects_cache_for object, solid_tags
        cached = @cache[object]
        update_colliding_objects_cache_for object, solid_tags  unless (
          cached                                     &&
          (cached[:position] == object.get_position) &&
          (cached[:size]     == object.get_size)
        )
      end

      def update_colliding_objects_cache_for object, solid_tags
        @cache[object] ||= {}
        @cache[object][:position]          = object.get_position.dup
        @cache[object][:size]              = object.get_size.dup
        @cache[object][:colliding_objects] = get_quadtrees_for(solid_tags).map do |quadtree|
          next quadtree.get_colliding_objects(object)
        end .flatten
      end
  end
end

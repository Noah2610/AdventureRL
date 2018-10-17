module AdventureRL
  class SolidsManager
    DEFAULT_SOLID_TAG = :default

    DEFAULT_SETTINGS = Settings.new(
      use_cache: false
    )

    def initialize settings = {}
      @settings    = DEFAULT_SETTINGS.merge settings
      @quadtrees   = {}
      @reset_queue = {}
      @cache       = {}
      @use_cache   = @settings.get :use_cache

      # Objects as keys pointing to the Quadtrees that they are in.
      @object_quadtrees = {}
    end

    # Add one (or multiple) <tt>object</tt>(s)
    # with one (or multiple) <tt>solid_tag</tt>(s).
    def add_object object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      solid_tags.each do |tag|
        if (@quadtrees[tag])
          @quadtrees[tag].add_object objects
        else
          @quadtrees[tag] = Quadtree.new objects: objects
        end
      end
    end
    alias_method :add, :add_object

    def remove_object object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      objects.each do |obj|
        @cache.delete obj
      end
      get_quadtrees_for(solid_tags).each do |quadtree|
        quadtree.remove_object objects
      end
    end
    alias_method :remove, :remove_object

    def remove_object_from_all_quadtrees object
      objects    = [object].flatten
      objects.each do |obj|
        @cache.delete obj
      end
      @quadtrees.values.flatten.each do |quadtree|
        quadtree.remove_object objects
      end
    end
    alias_method :remove_from_all_quadtrees, :remove_object_from_all_quadtrees

    # Returns <tt>true</tt> if the given <tt>object</tt> (or multiple objects),
    # collide with any other objects with a mutual <tt>solid_tag</tt>.
    def collides? object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      return objects.any? do |obj|
        handle_collides_cache_for obj, solid_tags
        next @cache[obj][:collides?]
      end  if (@use_cache)
      return objects.any? do |obj|
        next get_quadtrees_for(solid_tags).any? do |quadtree|
          next quadtree.collides?(obj)
        end
      end
    end

    # Returns all objects colliding with <tt>object</tt>(s).
    def get_colliding_objects object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten
      return objects.map do |obj|
        handle_colliding_objects_cache_for obj, solid_tags
        next @cache[obj][:colliding_objects]
      end .flatten  if (@use_cache)
      return objects.map do |obj|
        next get_quadtrees_for(solid_tags).map do |quadtree|
          next quadtree.get_colliding_objects(obj)
        end
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
        return solid_tags.map do |tag|
          next @quadtrees[tag]
        end .compact
      end

      def handle_collides_cache_for object, solid_tags
        cached = @cache[object]
        update_collides_cache_for object, solid_tags  unless (
          # TODO: Remove cache or improve, it can break stuff
          @use_cache &&
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
          # TODO: Remove cache or improve, it can break stuff
          @use_cache &&
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

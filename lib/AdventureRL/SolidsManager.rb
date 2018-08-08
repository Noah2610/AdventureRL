module AdventureRL
  class SolidsManager
    DEFAULT_SOLID_TAG = :default

    def initialize
      @quadtrees     = {}
      @objects       = {}
      @has_reset_for = []
      @reset_queue = {}
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
      return @quadtrees.map do |quadtree_tag, quadtree|
        next quadtree  if (solid_tags.include?(quadtree_tag))
        next nil
      end .compact.any? do |quadtree|
        next objects.any? do |obj|
          next quadtree.get_colliding_objects(obj).any?
        end
      end
    end

    # Resets all Quadtrees for all Mask objects
    # with given <tt>solid_tag</tt>(s).
    def reset_for solid_tag = DEFAULT_SOLID_TAG
      solid_tags = [solid_tag].flatten
      return  if (solid_tags.all? { |tag| @has_reset_for.include?(tag) })
      @quadtrees.map do |quadtree_tag, quadtree|
        if (solid_tags.include?(quadtree_tag) && !@has_reset_for.include?(quadtree_tag))
          @has_reset_for << quadtree_tag
          next quadtree
        end
        next nil
      end #.compact.each do |quadtree|  #(&:reset)
        # quadtree.reset
        # quadtree.add_object @objects[reset_tag]
      # end
      @has_reset_for.each do |reset_tag|
        #@quadtrees[reset_tag] = Quadtree.new objects: @objects[reset_tag]
        @quadtrees[reset_tag].reset
        @quadtrees[reset_tag].add_object @objects[reset_tag]
      end
    end

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

    # Called once every frame by Window.
    def update
      reset
      @has_reset_for = []
    end

    # TODO
    def draw
      @quadtrees.values.each &:draw
    end
  end
end

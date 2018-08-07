module AdventureRL
  class SolidsManager
    DEFAULT_SOLID_TAG = :default

    def initialize
      @quadtrees = {
        [DEFAULT_SOLID_TAG] => Quadtree.new
      }
    end

    # Add one (or multiple) <tt>object</tt>(s)
    # with one (or multiple) <tt>solid_tag</tt>(s).
    def add_object object, solid_tag = DEFAULT_SOLID_TAG
      objects    = [object].flatten
      solid_tags = [solid_tag].flatten.sort
      @quadtrees[solid_tags] = Quadtree.new objects: objects
    end

    # Resets all Quadtrees for all Mask objects
    # with given <tt>solid_tag</tt>(s).
    def reset_for solid_tag = DEFAULT_SOLID_TAG
      solid_tags = [solid_tag].flatten.sort
      quadtree = @quadtrees[solid_tags]
      quadtree.reset  if (quadtree)
    end
  end
end

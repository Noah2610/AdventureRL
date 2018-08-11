module AdventureRL
  class Camera < Layer
    DEFAULT_SETTINGS = Settings.new(
      process_offscreen: false,  # Boolean or Array of objects / ids, which should be processed when offscreen
      following:         nil
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      super @settings
      @view_port = Mask.new(
        position: {
          x: 0,
          y: 0
        },
        size: get_size,
        origin: {
          x: :center,
          y: :center
        }
      )
      @process_offscreen_objects = @settings.get(:process_offscreen) || []
      @following                 = @settings.get :following
    end

    # Overwrite #add_object method, so we can
    # set the object as offscreen processable, if the passed <tt>id</tt>
    # was also passed as a <tt>process_offscreen</tt> id on initialization
    # OR additional third argument is <tt>true</tt>.
    def add_object object, id = DEFAULT_INVENTORY_ID, process_offscreen = false
      id ||= DEFAULT_INVENTORY_ID
      super object, id
      @process_offscreen_objects << object  if (process_offscreen || @process_offscreen_objects.include?(id))
    end
    alias_method :add_item,  :add_object
    alias_method :add,       :add_object
    alias_method :<<,        :add_object

    # Overwrite Inventory#get_objects method, to only
    # return objects that are in the Camera's view.
    def get_objects *args
      objects = super
      return objects.select do |object|
        next @process_offscreen_objects.include?(object) || collides_with?(object)
      end
    end

    # Returns all objects, optionally with given <tt>id</tt>.
    # Ignores <tt>@process_offscreen_objects</tt>.
    def get_all_objects id = nil
      return @inventory.values.flatten  unless (id)
      return @inventory[id]
    end

    # Make the Camera follow the given <tt>object</tt>.
    # <tt>object</tt> may also be an the id of an object.
    def follow object
      obj = get_object object
      obj = get_all_objects.detect { |o| next o == object }  unless (obj)
      @following = obj
    end

    # Overwrite #update method, so we can
    # follow an object, if necessary
    def update
      super

      if (@following)
        # TODO: FIGURE THIS OUT!!!
        center = @following.get_center
        #@view_port.set_position center.x * -1, center.y * -1  # why * -1 ???
        @view_port.set_position center.x, center.y  # why * -1 ???
        #puts @view_port.get_position
        #set_center_position @following.get_center  if (@following)
        #@view_port.set_center_position @following.get_center  if (@following)
      end
    end

    def draw
      super
      Gosu.scale(@scale[:x], @scale[:y], x, y) do
        Gosu.rotate(@rotation, *get_center.values) do
          Gosu.translate(*@view_port.get_corner(:left, :top).get_position.values) do
            call_method_on_children :draw
          end
        end
      end
    end
  end
end

module AdventureRL
  module Events
    class Mouse < Event
      def initialize *args
        super
        @quadtree = Quadtree.new
      end

      # Overwrite the #add_object method, so we can
      # reset the object in the Quadtree if necessary,
      # via the object's #move_by method.
      def add_object object
        super
        [object].flatten.each do |obj|
          get_quadtree.add_object obj
          mouse_event = self
          obj.define_singleton_method :move_by do |*args|
            previous_position = get_position.dup
            super(*args)
            mouse_event.get_quadtree.reset_object self  if (get_position != previous_position)
          end
        end
      end

      # Overwrite the #remove_object method, so we can
      # also remove the object(s) from the Quadtree.
      def remove_object object
        super
        [object].flatten.each do |obj|
          get_quadtree.remove_object obj
        end
      end

      # Overwrite the #trigger method, to perform a
      # Quadtree query for objects colliding with the mouse pointer.
      # For improved performance.
      def trigger *args
        get_colliding_objects.each do |object|
          @trigger_method.call object, *args
        end
      end

      def get_quadtree
        return @quadtree
      end

      private

        def get_colliding_objects
          return get_quadtree.get_colliding_objects_for get_mouse_point
        end

        def get_mouse_point
          window = Window.get_window
          return nil  unless (window)
          return Point.new(window.mouse_x, window.mouse_y)
        end
    end
  end
end

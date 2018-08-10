module AdventureRL
  module Modifiers
    module Inventory
      DEFAULT_INVENTORY_ID = :NO_NAME

      def initialize *args
        super
        @inventory = {}
      end

      # Add any object to this Inventory.
      # Pass an optional <tt>id</tt>, which can be used to
      # access or remove the object afterwards.
      def add_object object, id = DEFAULT_INVENTORY_ID
        @inventory[id] = []  unless (@inventory[id])
        @inventory[id] << object
      end
      alias_method :add_item, :add_object
      alias_method :add,      :add_object
      alias_method :<<,       :add_object

      # Returns true, if object with <tt>id</tt> has been added to this Inventory.
      # <tt>id</tt> can also be the object itself.
      def added_object? id
        return (
          @inventory.key?(id) ||
          get_objects.include?(id)
        )
      end
      alias_method :added_item?, :added_object?
      alias_method :added?,      :added_object?
      alias_method :has?,        :added_object?

      # Returns all its objects.
      # If optional argument <tt>id</tt> is passed,
      # then return all objects with that <tt>id</tt>.
      def get_objects id = nil
        return @inventory.values.flatten  unless (id)
        return @inventory[id]
      end

      # Returns the _last_ object with the given <tt>id</tt>.
      # If no <tt>id</tt> is passed, return the last object with the unnamed <tt>id</tt>.
      def get_object id = DEFAULT_INVENTORY_ID
        return @inventory[id].last
      end
      alias_method :get, :get_object

      # Removes all objects with the given <tt>id</tt>.
      # <tt>id</tt> can also be an added object itself;
      # all objects with the same <tt>id</tt> will be removed.
      # If no <tt>id</tt> is given, remove _all_ objects.
      def remove_objects id = nil
        return @inventory.clear      unless (id)
        return @inventory.delete id  if     (@inventory.key? id)
        return @inventory.delete((@inventory.detect do |key, val|
          next id == val
        end || []).first)
      end

      # Removes the _last_ object with the given <tt>id</tt>.
      # <tt>id</tt> can also be the object to be removed itself.
      # If no <tt>id</tt> is given, remove the _last_ object with the unnamed <tt>id</tt>.
      def remove_object id = DEFAULT_INVENTORY_ID
        return @inventory[id].delete_at -1  if (@inventory.key? id)
        key = (@inventory.detect do |key, val|
          next id == val
        end || []) .first
        return @inventory[key].delete id
      end
      alias_method :remove, :remove_object
    end
  end
end

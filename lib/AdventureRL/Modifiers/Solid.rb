module AdventureRL
  module Modifiers
    # This module is supposed to be <tt>include</tt>d in Mask child classes.
    # It will tag that Mask instance as <tt>'solid'</tt>,
    # and check collision with other solid Masks when calling #move_by.
    # You can give it a specific <tt>solid_tag</tt>, which can be passed as
    # the <tt>:solid_tag</tt> key's value upon initialization.
    # Multiple solid tags may be passed as an array.
    # Solid Masks will only collide with other Solid Masks that have a mutual solid tag.
    # The default solid tag is <tt>:default</tt>.
    module Solid
      DEFAULT_SOLID_SETTINGS = Settings.new(
        solid_tag: SolidsManager::DEFAULT_SOLID_TAG
      )

      # Additionally to the Mask's settings Hash or Settings instance,
      # you may pass the extra key <tt>:solid_tag</tt>, to define
      # a custom solid tag (or multiple solid tags) upon initialization.
      # They are used for collision checking with other Solid Mask objects
      # that have a mutual solid tag.
      def initialize settings = {}
        solid_settings = DEFAULT_SOLID_SETTINGS.merge settings
        @solid_tags    = [solid_settings.get(:solid_tag)].flatten.sort
        super
        Window.get_window.get_solids_manager.add_object self, @solid_tags
      end

      # Overwrite #move_by method, so that collision checking with other objects
      # with a mutual solid tag is done, and movement prevented if necessary.
      def move_by *args
        previous_position = get_position
        # Check collision with other objects with a mutual solid tag,
        # via SolidsManager.
        #
        # Update SolidsManager with @solid_tags, if this Mask was moved.
      end
    end
  end
end

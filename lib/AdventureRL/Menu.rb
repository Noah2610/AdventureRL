module AdventureRL
  class Menu < Layer
    # This Array will be filled with creaed Menus.
    MENUS = []

    def self.button_down btnid
      get_active_menus.each do |menu|
        menu.button_down btnid
      end
    end
    def self.button_up btnid
      get_active_menus.each do |menu|
        menu.button_up btnid
      end
    end
    def self.update
      get_active_menus.each(&:update)
    end
    def self.get_active_menus
      return MENUS.select(&:is_active?)
    end

    DEFAULT_SETTINGS = Settings.new(
      active:         false,
      auto_update:    false,
      mouse_buttons_event_handler: {
        auto_update:        false,
        only_mouse_buttons: true
      }
    )

    def initialize settings = {}
      @settings = DEFAULT_SETTINGS.merge settings
      @mouse_buttons_event_handler = EventHandlers::MouseButtons.new @settings.get(:mouse_buttons_event_handler)
      super @settings
      @active = @settings.get :active
      MENUS << self  if (@settings.get(:auto_update))
    end

    # Overwrite #add_object method, so we can
    # validate, that the given <tt>object</tt> is a Button.
    def add_object object, id = DEFAULT_INVENTORY_ID
      #Helpers::Error.error(
      #  "Expected given object to be a Button, but got",
      #  "'#{object.inspect}:#{object.class.name}`."
      #)  unless (object.is_a? Button)
      super
      @mouse_buttons_event_handler.subscribe object  if (object.is_a? Button)
    end
    alias_method :add_button, :add_object
    alias_method :add_item,   :add_object
    alias_method :add,        :add_object
    alias_method :<<,         :add_object

    def activate
      @active = true
    end

    def deactivate
      @active = false
    end

    def is_active?
      return !!@active
    end

    def is_inactive?
      return !is_active?
    end

    def button_down btnid
      return  if (is_inactive?)
      @mouse_buttons_event_handler.button_down btnid
    end

    def button_up btnid
      return  if (is_inactive?)
      @mouse_buttons_event_handler.button_up btnid
    end

    def update
      return  if (is_inactive?)
      @mouse_buttons_event_handler.update
      super
    end

    def draw
      return  if (is_inactive?)
      super
    end
  end
end

# `AdventureRL::Window`
This class inherits from `Gosu::Window`.  
It is responsible for the actual window updating and drawing.

__Table of Contents__
- [Methods](#methods)
  - [`initialize`](#initialize)
  - [`setup`](#setup)
  - [`get_size`](#get_size)
  - [`get_center`](#get_center)
  - [`get_fps`](#get_fps)
  - [`get_deltatime`](#get_deltatime)
  - [`get_tick`](#get_tick)
- [Gosu Methods](#gosu-methods)
  - [`update` and `draw`](#update-and-draw)
- [Example Window Initialization](#example-window-initialization)

## Methods
### `initialize`
```ruby
def initialize args = {}
end
```
Unlike with Gosu, the `#initialize` method should _not_ be overwritten.  
Instead, define the method `#setup`, which will be called after `#initialize`.  
You should pass a hash of settings to `#initialize`,  
which will also be passed to `#setup`, if `#setup` takes an argument.  
An example hash for `args`:
```ruby
AdventureRL::Window.new({
  size: {
    width:  960,
    height: 540
  },
  caption: 'My AdventureRL Game!'
})
```
You can pass anything you want in the hash and use it in your `#setup` method.  
For any mandatory hashes you don't pass _(such as `:size`)_ the defaults  
will be used, which is defined in the gem's root in `default_settings.yml`.

### `setup`
```ruby
def setup args
end
```
As mentioned above, this method is supposed to be overwritten by the developer.  
It will be called after `#initialize` has finished.  
You do not have to define it with taking an argument, but if you don't  
the arguments you passed to `#initialize` (`.new`) will not be available to you  
in `#setup`.

### `get_size`
```ruby
def get_size target = :all
end
```
This method returns the window's size. Depending on what `target` was given,  
it will return a different value:

- `:all` _(default)_  
  Will return a hash with `:width` and `:height` keys, for example:
  ```ruby
  {
    width:  960,
    height: 540
  }
  ```
- `:width` or `:height`  
  Will return the specified axis, so `get_size(:width)` will return `960`.

### `get_center`
```ruby
def get_center
end
```
Returns an `AdventureRL::Point` instance of the center of the window,  
assuming the top-left corner of the window is `0, 0`  
and the bottom-right corner is `get_size(:width), get_size(:height)`.

### `get_fps`
```ruby
def get_fps
end
```
Returns current frame rate. This is just a wrapper method for `Gosu.fps`.  
I decided to add this just to follow the design pattern with `get_*` methods.

### `get_deltatime`
```ruby
def get_deltatime
end
```
This method returns a float, representing the time difference in seconds  
to the last call to update. Using deltatime you can prevent your game from  
running at a different speed on slower computers.  
Read more about __deltatime__ at [gamedev.stackexchange.com][gamedev-deltatime-url].

### `get_tick`
```ruby
def get_tick
end
```
This method returns an integer, which is increased by one  
everytime `#update` is called. __*__

> __Attention__  
> Methods marked with an asterisk _(*)_ are only available  
> if you call `super` at the end of `#update`.

## Gosu Methods
The following methods come from the gosu gem's `Gosu::Window` class,  
as `AdventureRL::Window` inherits from `Gosu::Window`,  
all of gosu's window methods are available to you.  
Here are some examples of useful/necessary `Gosu::Window` methods.

### `update` and `draw`
```ruby
def update
  # This method is called every frame.
  # You're supposed to do handle any calculations your game does here,
  # such as player movement, mouse clicks, etc.
end
def draw
  # This method is also called every frame, after the #update method.
  # Here, you are supposed to handle the drawing of your images, textures, etc.
end
```
You should call `super` at the end of `#update`.  
If you don't, you will not be able to use a lot of methods  
and features provided by AdventureRL, such as `#get_deltatime` or `#get_tick`.

Check out [Gosu's documentation][gosu-window-doc] for a list of available methods.

## Example Window Initialization
```ruby
class MyGame < AdventureRL::Window
  def setup args
    self.caption = 'I prefer this window title!'
    @my_settings = AdventureRL::Settings.new 'path/to/my_settings.yml'
    @font = Gosu::Font.new 24
    # ...
  end

  private

  def update
    puts "Current tick: #{get_tick}"  # Prints the current tick to stdout.
    super  # Call the parent's #update method to have access to a lot of useful methods.
  end

  def draw
    center_point = get_center
    @font.draw_rel(
      "Delta-Time:\n#{get_deltatime}",
      center_point.x, center_point.y, 0,
      0.5, 0.5, 1, 1,
      0xff_00ff00
    )
  end
end

my_game = MyGame.new
my_game.show  # Actually open and render the window
              # and start your game loops #update and #draw.
```

[gamedev-deltatime-url]: https://gamedev.stackexchange.com/questions/1589/when-should-i-use-a-fixed-or-variable-time-step
[gosu-window-doc]:       https://www.rubydoc.info/github/gosu/gosu/Gosu/Window

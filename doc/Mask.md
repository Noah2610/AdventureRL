# `AdventureRL::Mask`
The mask is a two dimensional area.  
It has a `position`, `size`, and `origin`.

The mask should make collision checking and the like easier.

__Table of Contents__
- [Methods](#methods)
  - [`initialize`](#initialize)
  - [`collides_with?`](#collides_with)
  - [`get_point`](#get_point)
  - [`get_position`](#get_position)
  - [`get_size`](#get_size)
  - [`get_origin`](#get_origin)
  - [`get_corner`](#get_corner)
  - [`get_side`](#get_side)
  - [`get_center`](#get_center)

## Methods
### `initialize`
```ruby
def initialize args = {}
end
```
The mask has the following attributes,  
which should be passed as a hash on initialization:

- `position`  
  The starting position of the mask, relative to its `origin`.  
  This can be a hash with the keys `x` and `y`, or a `AdventureRL::Point`.
- `size`  
  The size of the mask. It is passed as a hash with the keys  
  `width` and `height`.
- `origin`  
  The origin of the mask is where the `position` is located on the mask.  
  It is passed as a hash with the keys `x` and `y`, and their values can be:
  - for `:x` - `:left`
  - for `:x` - `:right`
  - for `:y` - `:top`
  - for `:y` - `:bottom`
  - for `:x` or `:y` - `center`

  Usually, if you only use the mask's methods, the origin position should be  
  irrelevant to you, and you can ommit it. The only method which's output  
  it effects, is `#get_position`, as it will give you the point you initially  
  passed, which is the point where the origin position is.

If any or all of the above values are not passed, the defaults are used:
```ruby
{
  position: {
    x: 0,
    y: 0
  },
  size: {
    width:  64,
    height: 64
  },
  origin: {
    x: :left,
    y: :top
  }
}
```

### `collides_with?`
```ruby
def collides_with? point_or_mask
end
```
This method checks if it is in collision / overlapping with  
a `AdventureRL::Point` or `Adventure::Mask`; the argument accepts both.

### `get_point`
```ruby
def get_point
end
```
Returns the point with the positions passed to it initially.

### `get_position`
```ruby
def get_position target = :all
end
```
Returns its position, same as `get_point.get_position`.

### `get_size`
```ruby
def get_size target = :all
end
```
Returns its size, similar to `#get_position`,  
only with its sides, `width` and `height`.

### `get_origin`
```ruby
def get_origin
end
```
Returns its size, similar to `#get_position`,  
only with its origin axes, `x` and `y`.

### `get_corner`
```ruby
def get_corner side_x, side_y
end
```
Returns a point with the corner position of the given `side_x` and `side_y`.  
For example:
```ruby
mask = AdventureRL::Mask.new( ... )
mask.get_corner :left, :top       # => Returns point with top-left corner position.
mask.get_corner :right, :bottom   # => Returns point with botton-right corner position.
mask.get_corner :center, :center  # => Returns center point - same 
```

### `get_side`
```ruby
def get_side target
end
```
Returns an integer of the axis for the given target side.  
For example:
```ruby
mask = AdventureRL::Mask.new( ... )
mask.get_side :left  # => Returns x axis of the left mask edge.
mask.get_side :top   # => Returns y axis of the top mask edge.
```

### `get_center`
```ruby
def get_center target = :all
end
```
If target is `:all`, returns a new point with the center position of the mask.  
Otherwise, if target is `:x` or `:y`, returns an integer representing  
the center of the target's axis.

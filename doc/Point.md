# `AdventureRL::Point`
A point is a two dimensional vector.  
it has an `x` axis and a `y` axis.  
It should be pretty straight-forward and self-explanatory.

__Table of Contents__
- [Methods](#methods)
  - [`initialize`](#initialize)
  - [`x`](#x)
  - [`y`](#y)
  - [`get_position`](#get_position)
  - [`collides_with?`](#collides_with)
  - [`keys`](#keys)
  - [`values`](#values)

## Methods
### `initialize`
```ruby
def initialize x, y
end
```
Create a new point with `x` and `y` axes.

### `x`
```ruby
def x
end
```
Returns the integer for its `x` axis.

### `y`
```ruby
def y
end
```
Returns the integer for its `y` axis.

### `get_position`
```ruby
def get_position target = :all
end
alias_method :get_pos,  :get_position
alias_method :position, :get_position
alias_method :pos,      :get_position
```
Returns either both axes as a hash if target is `:all` or is ommited,  
or returns the value of target's axis.

### `collides_with?`
```ruby
def collides_with? point_or_mask
end
```
This method checks if it is in collision / overlapping with  
a `AdventureRL::Point` or `Adventure::Mask`; the argument accepts both.

### `keys`
```ruby
def keys
end
```
Returns the symbols `:x` and `:y` in an array, respectively.  
Based on `Hash#keys`.

### `values`
```ruby
def values
end
```
Returns the `:x` and `:y` axes in an array, respectively.  
Based on `Hash#values`.

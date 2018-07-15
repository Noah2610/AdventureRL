class PointTest < Minitest::Test
  include TestHelper

  def setup
    reset
  end

  def reset
    @point        = Point.new(16, 32)
    @point_nocoll = Point.new(64, 64)
    @point_coll   = Point.new(16, 32)
    @pos_nocoll   = { x: 32, y: 64 }
    @pos_coll     = { x: 16, y: 32 }
  end

  def test_that_points_dont_collide
    data = get_data([
      @point.get_position,
      @point_nocoll.get_position
    ])
    assert_equal false, @point.collides_with?(@point_nocoll), "Points should not collide:\n#{data}"
  end

  def test_that_points_collide
    data = get_data([
      @point.get_position,
      @point_coll.get_position
    ])
    assert_equal true, @point.collides_with?(@point_coll), "Points should collide:\n#{data}"
  end

  def test_that_point_doesnt_collide_with_hash
    data = get_data([
      @point.get_position,
      @pos_nocoll
    ])
    assert_equal false, @point.collides_with?(@pos_nocoll), "Point should not collide with Hash:\n#{data}"
  end

  def test_that_point_collides_with_hash
    data = get_data([
      @point.get_position,
      @pos_coll
    ])
    assert_equal true, @point.collides_with?(@pos_coll), "Point should collide with Hash:\n#{data}"
  end

  def test_that_points_real_position_is_correct
    pos      = @point.get_position
    real_pos = @point.get_real_position
    data = get_data({
      position: pos,
      real_pos: real_pos
    })
    assert_equal pos, real_pos, "Point's position should be it's real position:\n#{data}"
  end

  def test_can_set_position_x
    exp_pos = {
      x: @pos_nocoll[:x],
      y: @point.y
    }
    @point.set_position x: @pos_nocoll[:x]

    assert_equal exp_pos, @point.get_position, "Point's position x should have changed."

    reset
  end

  def test_can_set_position_y
    exp_pos = {
      x: @point.x,
      y: @pos_nocoll[:y]
    }
    @point.set_position y: @pos_nocoll[:y]

    assert_equal exp_pos, @point.get_position, "Point's position y should have changed."

    reset
  end

  def test_can_set_position
    @point.set_position *@pos_nocoll.values

    assert_equal @pos_nocoll, @point.get_position, "Point's position should have changed."

    reset
  end

  def test_can_move_by
    exp_pos = {
      x: @point.x + @pos_nocoll[:x],
      y: @point.y + @pos_nocoll[:y]
    }
    @point.move_by @pos_nocoll

    assert_equal exp_pos, @point.get_position, "Point's position should have changed."

    reset
  end

  def test_can_get_values
    assert_equal @point.get_position.values, @point.values
  end

  def test_can_get_keys
    assert_equal @point.get_position.keys, @point.keys
  end

  def test_can_assign_to
    obj = 'BLANK'
    @point.assign_to obj

    assert @point.assigned_to?(obj),                    "Point should be assigned to `obj'."
    assert_equal @point.get_position, obj.get_position, "Method should be piped to Point."

    reset
  end
end

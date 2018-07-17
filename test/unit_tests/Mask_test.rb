class MaskTest < UnitTest
  def setup
    reset
  end

  def reset
    @mask = Mask.new(
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
    )
    @sides = {
      left:  0,
      right: 64,
      top:   0,
      bottom: 64
    }
    @corners = {
      [:left,     :top] => { x: 0,  y: 0 },
      [:right,    :top] => { x: 64, y: 0 },
      [:left,  :bottom] => { x: 0,  y: 64 },
      [:right, :bottom] => { x: 64, y: 64 }
    }
    @center_pos = { x: 32, y: 32 }
    @mask_nocoll = Mask.new(
      position: {
        x: 65,
        y: 65
      },
      size: {
        width:  64,
        height: 64
      },
      origin: {
        x: :left,
        y: :top
      }
    )
    @mask_coll = Mask.new(
      position: {
        x: 32,
        y: 32
      },
      size: {
        width:  64,
        height: 64
      },
      origin: {
        x: :left,
        y: :top
      }
    )
    @point_nocoll = Point.new(65, 32)
    @point_coll   = Point.new(48, 32)
    @pos_nocoll   = { x: 96, y: 0 }
    @pos_coll     = { x: 63, y: 63 }
  end

  def test_that_masks_dont_collide
    data = get_data([
      {
        position: @mask.get_position,
        size:     @mask.get_size
      },
      {
        position: @mask_nocoll.get_position,
        size:     @mask_nocoll.get_size
      }
    ])
    assert_equal false, @mask.collides_with?(@mask_nocoll), "Masks should not collide:\n#{data}"
  end

  def test_that_masks_collide
    data = get_data([
      {
        position: @mask.get_position,
        size:     @mask.get_size
      },
      {
        position: @mask_coll.get_position,
        size:     @mask_coll.get_size
      }
    ])
    assert @mask.collides_with?(@mask_coll), "Masks should collide:\n#{data}"
  end

  def test_that_mask_doesnt_collide_with_point
    data = get_data([
      {
        position: @mask.get_position,
        size:     @mask.get_size
      },
      {
        position: @point_nocoll.get_position
      }
    ])
    assert_equal false, @mask.collides_with?(@point_nocoll), "Mask should not collide with Point:\n#{data}"
  end

  def test_that_mask_collides_with_point
    data = get_data([
      {
        position: @mask.get_position,
        size:     @mask.get_size
      },
      {
        position: @point_coll.get_position
      }
    ])
    assert @mask.collides_with?(@point_coll), "Mask should collide with Point:\n#{data}"
  end

  def test_that_mask_doesnt_collide_with_hash
    data = get_data([
      {
        position: @mask.get_position,
        size:     @mask.get_size
      },
      {
        position: @pos_nocoll
      }
    ])
    assert_equal false, @mask.collides_with?(@pos_nocoll), "Mask should not collide with Hash:\n#{data}"
  end

  def test_that_mask_collides_with_hash
    data = get_data([
      {
        position: @mask.get_position,
        size:     @mask.get_size
      },
      {
        position: @pos_coll
      }
    ])
    assert @mask.collides_with?(@pos_coll), "Mask should collide with Hash:\n#{data}"
  end

  def test_get_sides
    @sides.each do |side, pos|
      assert_equal pos, @mask.get_side(side), "Mask should get correct side."
    end
  end

  def test_get_real_sides
    @sides.each do |side, pos|
      assert_equal pos, @mask.get_real_side(side), "Mask should get correct real side."
    end
  end

  def test_get_corners
    @corners.each do |sides, pos|
      data = get_data(
        sides => pos
      )
      assert_equal pos, @mask.get_corner(*sides).get_position, "Mask should get correct corner:\n#{data}"
    end
  end

  def test_get_real_corners
    @corners.each do |sides, pos|
      data = get_data(
        sides => pos
      )
      assert_equal pos, @mask.get_real_corner(*sides).get_position, "Mask should get correct real corner:\n#{data}"
    end
  end

  def test_get_center
    assert_equal @center_pos, @mask.get_center.get_position, "Mask should get correct center position."
  end

  def test_get_real_center
    assert_equal @center_pos, @mask.get_real_center.get_position, "Mask should get correct real center position."
  end

  def test_can_assign_to
    obj = 'BLANK'
    @mask.assign_to obj

    assert @mask.assigned_to?(obj),            "Mask should be assigned to `obj'."
    assert_equal @mask.get_size, obj.get_size, "Method should be piped to Mask (and then to Point)."

    reset
  end
end

class LayerTest < UnitTest
  def setup
    reset
  end

  def reset
    @layer = Layer.new(
      mask: {
        position: {
          x: 0,
          y: 0
        },
        size: {
          width:  360,
          height: 360
        },
        origin: {
          x: :left,
          y: :top
        }
      }
    )
    @mask = Mask.new
  end

  def test_add_child
    @layer.add @mask, :mask

    assert @layer.added?(:mask), 'The Mask should be added to Layer (check by id).'
    assert @layer.added?(@mask), 'The Mask should be added to Layer (check by object).'

    reset
  end

  def test_get_child
    @layer.add @mask, :mask

    assert_equal @mask, @layer.get(:mask), 'Layer should return the Mask.'

    reset
  end

  def test_remove_child
    @layer.add @mask, :mask

    assert_equal @mask, @layer.remove(:mask), 'Should remove the Mask.'
    assert_equal false, @layer.has?(@mask),   'Layer should not have Mask anymore.'

    reset
  end
end

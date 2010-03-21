require File.dirname(__FILE__) + '/../test_helper'

class ColorTest < MoodlogTestCase
  fixtures :people, :moods

  def setup
    @palette = [
      @white =     Color.new(:value => 0xffffff),
      @black =     Color.new(:value => 0x000000),
      @red =       Color.new(:value => 0xff0000),
      @green =     Color.new(:value => 0x00ff00),
      @blue =      Color.new(:value => 0x0000ff),
      @fuchsia =   Color.new(:value => 0xff00ff),
      @purple =    Color.new(:value => 0x800080),
      @turquoise = Color.new(:value => 0x48D1CC),
                  Color.new(:value => 0x112233),
                  Color.new(:value => 0x001100),
                  Color.new(:value => 0x000011),
                  Color.new(:value => 0x000001),
    ]
  end
  
  def test_new_with_rgb
    color = Color.new(:rgb => "#ffffff")
    assert_equal 0xffffff, color.value
  end
  
  def test_create_with_rgb
    color = create_color(:rgb => "#ffffff")
    assert_equal 0xffffff, color.value
  end
  
  def test_create_with_rgb_case_insensitive
    color = create_color(:rgb => "#fFFfFF")
    assert_equal 0xffffff, color.value
  end
  
  def test_update_with_rgb
    color = create_color(:rgb => "#ffffff")
    color.update_attributes(:rgb => "#000011")
    assert_equal 0x000011, color.value
  end
  
  def test_get_rgb
    ["#ffffff", "#112233", "#001100", "#000011", "#000001", "#000000"].each do |s|
      color = create_color(:rgb => s)
      assert_equal s, color.rgb
    end
  end
  
  def test_to_rgb
    assert_equal "#dababe", Color.to_rgb(0xdababe)
    assert_equal Color::NEUTRAL, Color.to_rgb(nil)
  end
  
  def test_hsl_for_black
    black = create_color(:rgb => "#000000")
    assert_equal 0, black.hue
    assert_equal 0, black.saturation
    assert_equal 0, black.lightness
  end
  
  def test_hsl_for_white
    white = create_color(:rgb => "#FFFFFF")
    assert_equal 0, white.hue
    assert_equal 0, white.saturation
    assert_equal 1, white.lightness
  end
  
  def test_hsl_to_rgb
    random_colors.each do |color|
      # assert_between_0_and_1 color.hue  # todo: figure out why this is possible
      assert_between_0_and_1 color.saturation
      assert_between_0_and_1 color.lightness    
      assert_equal color.rgb, Color.from_hsl(color.hsl).rgb
    end
  end
  
  def assert_between_0_and_1(x)
    assert x >= 0, "#{x} should be >= 0"
    assert x <= 1.0 || approx_equal?(x, 1.0), "#{x} should be <= 1.0"
  end
  
  def approx_equal?(a,b,threshold = 0.0000001)
      (a-b).abs<threshold
  end
  
  
  def random_colors
    rgbs = @palette
    50.times { rgbs << Color.new(:rgb => "#%.6x" % rand(0x1000000).to_i) }
    rgbs
  end
  
  def test_contrast
    assert_equal "#ffffff", create_color(:rgb => "#000000").contrast
    assert_equal "#000000", create_color(:rgb => "#ffffff").contrast

    assert_equal "#000000", create_color(:rgb => "#888888").contrast
    assert_equal "#ffffff", create_color(:rgb => "#777777").contrast
    
    random_colors.each do |color|
      assert_equal color.lightness < 0.5 ? '#ffffff' : '#000000', color.contrast, color.rgb
    end
  end

  def test_consensus_where_none
    assert_nil Color.consensus(moods(:happy))
  end
  
  def test_consensus_where_one
    create_color(:person => people(:quentin), :mood => moods(:happy), :rgb => "#FF0000")
    assert_equal "#ff0000", Color.consensus(moods(:happy)).rgb
  end
  
  def test_parts
    assert_equal 0xff, @red.red
    assert_equal 0,    @green.red
    assert_equal 0,    @blue.red
    assert_equal 0xff, @fuchsia.red

    assert_equal 0x00, @red.green
    assert_equal 0xff, @green.green
    assert_equal 0x00, @blue.green
    assert_equal 0x00, @fuchsia.green
  end

  # todo: use HSL instead of RGB to find average
  # def test_consensus_where_many
  #   mood = moods(:happy)
  #   red_sum = green_sum = blue_sum = 0
  #   @palette.each_with_index do |x,i|
  #     person = Person.create!(:username => "person#{i}", 
  #       :password => 'test', :password_confirmation => 'test', 
  #       :addresses => {0 => {:email => "person#{i}@example.com"}})
  #     color = create_color(:person => person, :mood => mood, :rgb => x.rgb)
  #     red_sum += color.red
  #     green_sum += color.green
  #     blue_sum += color.blue
  #   end
  #   consensus = Color.consensus(mood)
  #   n = @palette.size
  #   assert_equal red_sum/n, consensus.red
  #   assert_equal blue_sum/n, consensus.blue
  #   assert_equal green_sum/n, consensus.green
  # end
  # 
  def test_consensus_where_many
    mood = moods(:happy)
    hue_sum = saturation_sum = lightness_sum = 0
    @palette.each_with_index do |x,i|
      person = Person.create!(:username => "person#{i}", 
        :password => 'test', :password_confirmation => 'test', 
        :addresses => {0 => {:email => "person#{i}@example.com"}})
      color = create_color(:person => person, :mood => mood, :rgb => x.rgb)
      hue_sum += color.hue
      saturation_sum += color.saturation
      lightness_sum += color.lightness
    end
    consensus = Color.consensus(mood)
    n = @palette.size
    assert_nearly_equal hue_sum/n, consensus.hue
    assert_nearly_equal lightness_sum/n, consensus.lightness
    assert_nearly_equal saturation_sum/n, consensus.saturation
  end
  
  def assert_nearly_equal(expected, actual)
    assert_equal((expected*10.0).round, (actual*10.0).round, "Expected #{expected} and #{actual} to be nearly equal")
  end
  
  def create_color(options = {})
    options = {:person => people(:quentin), :mood => moods(:happy)}.merge(options)
    Color.create(options)
  end
  
end

module Constants

  SIMPLE_PI = 4
  TOP_ANGLES = (-SIMPLE_PI..0)
  BOTTOM_ANGLES = (0..SIMPLE_PI)
  LEFT_ANGLES = [(-Math::PI/2)..(Math::PI/2)]
  RIGHT_ANGLES = [(Math::PI/2)..SIMPLE_PI, -SIMPLE_PI..(-Math::PI/2)]
  TOP_LEFT_CORNER_ANGLES = [(-Math::PI)..(-Math::PI/4), (3*Math::PI/4)..SIMPLE_PI]
  TOP_RIGHT_CORNER_ANGLES = [(-3*Math::PI/4)..(Math::PI/4)]
  BOTTOM_LEFT_CORNER_ANGLES = [(-Math::PI)..(-3*Math::PI/4), (Math::PI/4)..SIMPLE_PI]
  BOTTOM_RIGHT_CORNER_ANGLES = [(-Math::PI/4)..(3*Math::PI/4)]

  REACH_DISTANCE = 120 # rules (p.13)
  REACH_ANGLES = ((-Math::PI/12)..(Math::PI/12)) # rules (p.13)

  ENOUGH_STRIKE_ANGLE = 0.5 * Math::PI / 180
  STRIKE_POINT_X_FROM_MY_SIDE = 700
  STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE = 150

  def opponent_player
    $opponent_player ||= world.get_opponent_player
  end

  def opponent_on_the_left?
    return $opponent_on_the_left unless $opponent_on_the_left.nil?
    $opponent_on_the_left = opponent_player.net_left < rink_center_x
  end

  def opponent_net_center_x
    $opponent_net_center_x ||= opponent_on_the_left? ? opponent_player.net_right : opponent_player.net_left
  end

  def opponent_net_center_y
    $opponent_net_center_y ||= 0.5 * (opponent_player.net_top + opponent_player.net_bottom)
  end

  def my_net_center_x
    $my_net_center_x ||= opponent_on_the_left? ? my_player.net_left : my_player.net_right
  end

  def my_net_center_y
    $my_net_center_y ||= 0.5 * (my_player.net_top + my_player.net_bottom)
  end

  def rink_width
    $rink_width ||= game.rink_right-game.rink_left
  end

  def rink_height
    $rink_height ||= game.rink_bottom-game.rink_top
  end

  def rink_center_x
    $rink_center_x ||= (game.rink_right+game.rink_left) * 0.5
  end

  def left_section_xx
    $left_section_xx ||= game.rink_left..(game.rink_left + rink_width/2)
  end

  def right_section_xx
    $right_section_xx ||= (game.rink_left + rink_width/2)..game.rink_right
  end

  def far_section_xx
    $far_section_xx ||= opponent_on_the_left? ? left_section_xx : right_section_xx
  end

  def near_section_xx
    $near_section_xx ||= opponent_on_the_left? ? right_section_xx : left_section_xx
  end

  def top_section_yy
    $top_section_yy ||= game.rink_top..(game.rink_top + rink_height/2)
  end

  def bottom_section_yy
    $bottom_section_yy ||= (game.rink_top + rink_height/2)..game.rink_bottom
  end

  alias_method :top_far_section_xx, :far_section_xx
  alias_method :top_far_section_yy, :top_section_yy
  alias_method :bottom_far_section_xx, :far_section_xx
  alias_method :bottom_far_section_yy, :bottom_section_yy
  alias_method :top_near_section_xx, :near_section_xx
  alias_method :top_near_section_yy, :top_section_yy
  alias_method :bottom_near_section_xx, :near_section_xx
  alias_method :bottom_near_section_yy, :bottom_section_yy

  def back_angles
    $back_angles ||= opponent_on_the_left? ? LEFT_ANGLES : RIGHT_ANGLES
  end

  def forward_angles
    $forward_angles ||= opponent_on_the_left? ? RIGHT_ANGLES : LEFT_ANGLES
  end

  def top_far_corner_angles
    $top_far_corner_angles ||= opponent_on_the_left? ? TOP_LEFT_CORNER_ANGLES : TOP_RIGHT_CORNER_ANGLES
  end

  def top_near_corner_angles
    $top_near_corner_angles ||= opponent_on_the_left? ? TOP_RIGHT_CORNER_ANGLES : TOP_LEFT_CORNER_ANGLES
  end

  def bottom_far_corner_angles
    $bottom_far_corner_angles ||= opponent_on_the_left? ? BOTTOM_LEFT_CORNER_ANGLES : BOTTOM_RIGHT_CORNER_ANGLES
  end

  def bottom_near_corner_angles
    $bottom_near_corner_angles ||= opponent_on_the_left? ? BOTTOM_RIGHT_CORNER_ANGLES : BOTTOM_LEFT_CORNER_ANGLES
  end

  def top_strike_point_x
    $top_strike_point_x ||= x_from_my_vertical_side(STRIKE_POINT_X_FROM_MY_SIDE)
  end

  def top_strike_point_y
    $top_strike_point_y ||= game.rink_top + STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE
  end

  alias_method :bottom_strike_point_x, :top_strike_point_x

  def bottom_strike_point_y
    $bottom_strike_point_y ||= game.rink_bottom - STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE
  end

  alias_method :top_middle_point_x, :rink_center_x
  alias_method :top_middle_point_y, :top_strike_point_y
  alias_method :bottom_middle_point_x, :top_middle_point_x
  alias_method :bottom_middle_point_y, :bottom_strike_point_y

  def defending_point_x
    $defending_point_x ||= x_from_my_vertical_side(120)
  end

  def defending_point_y
    $defending_point_y ||= my_net_center_y
  end

end

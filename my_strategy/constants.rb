module Constants

  REACH_DISTANCE = 120 # rules (p.13)
  REACH_ANGLES = ((-Math::PI/12)..(Math::PI/12)) # rules (p.13)

  ENOUGH_STRIKE_ANGLE = 0.5 * Math::PI / 180
  STRIKE_POINT_X_FROM_MY_SIDE = 700
  STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE = 150

  def opponent_on_the_left?
    $opponent_on_the_left = opponent_player.net_left < rink_center_x if $opponent_on_the_left.nil?
    $opponent_on_the_left
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

  def rink_center_y
    $rink_center_y ||= (game.rink_bottom+game.rink_top) * 0.5
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

  def top_near_point_x
    $top_near_point_x ||= x_from_my_vertical_side(400)
  end

  alias_method :top_near_point_y, :my_net_center_y
  alias_method :bottom_near_point_x, :top_near_point_x
  alias_method :bottom_near_point_y, :top_near_point_y

  def defending_point_x
    $defending_point_x ||= x_from_my_vertical_side(120)
  end

  def defending_point_y
    $defending_point_y ||= my_net_center_y
  end

end

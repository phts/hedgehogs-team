require "./model/hockeyist_type"
require_relative 'constants'

module Utils

  def in_top_section?(unit)
    unit.y <= rink_center_y
  end

  def in_right_section?(unit)
    unit.x >= rink_center_x
  end

  def in_left_section?(unit)
    unit.x <= rink_center_x
  end

  def in_near_section?(unit)
    opponent_on_the_left? ? in_right_section?(unit) : in_left_section?(unit)
  end

  def x_from_my_vertical_side(value)
    my_net_center_x + (opponent_on_the_left? ? -value : value)
  end

  def me_nearer_than?(value)
    opponent_on_the_left? ? (me.x > value) : (me.x < value)
  end

  def player_hockeyists(player_id, except = nil)
    world.hockeyists.select{ |h| h.player_id == player_id && (except.nil? || h.id != except.id) && h.type != HockeyistType::GOALIE }
  end

  def nearest_hockeyist_to_unit(player_id, unit, except = nil)
    player_hockeyists(player_id, except).min_by{ |h| h.get_distance_to_unit(unit) }
  end

  def nearest_hockeyist_to(player_id, x, y)
    player_hockeyists(player_id).min_by{ |h| h.get_distance_to(x, y) }
  end

  def nearest_my_hockeyist_to_unit(unit, except = nil)
    nearest_hockeyist_to_unit(my_player.id, unit, except)
  end

  def nearest_opponent_hockeyist_to_unit(unit)
    nearest_hockeyist_to_unit(opponent_player.id, unit)
  end

  def nearest_opponent_hockeyist_to(x, y)
    nearest_hockeyist_to(opponent_player.id, x, y)
  end

  def reachable_unit?(unit)
    me.get_distance_to_unit(unit) <= Constants::REACH_DISTANCE && Constants::REACH_ANGLES.include?(me.get_angle_to_unit(unit))
  end

  def reachable_opponent_hockeyist
    player_hockeyists(opponent_player.id).each do |h|
      return h if reachable_unit?(h)
    end
    nil
  end

  def opposite_angle(angle)
    return Math::PI if angle == 0
    return 0 if angle.abs == Math::PI
    angle < 0 ? angle+Math::PI : angle-Math::PI
  end

  def units_equal?(u1, u2)
    u1.id == u2.id
  end

  def overtime?
    world.tick >= world.tick_count
  end

  def losing_more_than_by?(points)
    opponent_player.goal_count - my_player.goal_count >= points
  end

  def losing?
    my_player.goal_count < opponent_player.goal_count
  end

  def winning?
    my_player.goal_count > opponent_player.goal_count
  end

  def game_ends_in_less_than?(tick_count)
    world.tick_count - world.tick <= tick_count
  end

  def panic_mode?
    !!$panic_mode
  end

  def go_to_unit(unit)
    movee.speed_up = 1.0
    fast_turn(me.get_angle_to_unit(unit))
    movee.action = ActionType::TAKE_PUCK
    try_to_knock_down_opponent
  end

  def fast_turn(angle)
    if angle.abs < Constants::FAST_TURN_ENOUGH_ANGLE
      movee.turn = angle
      return
    end
    movee.turn = angle > 0 ? Math::PI : -Math::PI
  end

  def debug(message = nil)
    puts "#{message}"
    puts "   #{me.teammate_index+1} x:#{me.x} y:#{me.y} a:#{me.angle}"
    puts "   speed_up:#{movee.speed_up} turn:#{movee.turn} action:#{movee.action}"
  end

end

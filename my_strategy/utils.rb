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

  def in_far_section?(unit)
    opponent_on_the_left? ? in_left_section?(unit) : in_right_section?(unit)
  end

  def x_from_my_vertical_side(value)
    my_net_center_x + (opponent_on_the_left? ? -value : value)
  end

  def me_nearer_than?(value)
    opponent_on_the_left? ? (me.x > value) : (me.x < value)
  end

  def my_hockeyists_own_puck?
    world.puck.owner_player_id == me.player_id
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

  def opponent_hockeyists_nearer_to_unit_than(unit, distance)
    arr = []
    player_hockeyists(opponent_player.id).each do |h|
      arr << h if unit.get_distance_to_unit(h) < distance
    end
    arr
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

  def unit_speed(unit)
    Math::sqrt(unit.speed_x**2 + unit.speed_y**2)
  end

  def go_to_angle(angle)
    movee.speed_up = 1.0
    fast_turn(angle)
    unless my_hockeyists_own_puck?
      movee.action = ActionType::TAKE_PUCK
    end
    try_to_knock_down_opponent
  end

  def go_to_unit(unit)
    go_to_angle(me.get_angle_to_unit(unit))
  end

  def go_to_moving_unit(unit)
    go_to_unit(unit)
    if unit_moves_in_opposite_direction?(me, unit)
      # if unit moves in an opposite direction to me
      angle_to_unit = if me.get_distance_to_unit(unit) > 100
                        # if unit is too far
                        # then calc angle to its future position to be able to take it fast
                        future_pos = future_position(unit)
                        me.get_angle_to(future_pos[0], future_pos[1])
                      else
                        me.get_angle_to_unit(unit)
                      end
      if angle_to_unit.abs < Math::PI/2
        # move to each other
        movee.turn = angle_to_unit
      else
        # move from each other
        unless unit_speed(me) < 5
          # if me moves fast
          # then stop and turn
          movee.speed_up = -1.0
        end
      end
    end
  end

  def future_position(unit)
    future_distance = unit_speed(unit) * 20 # distance in 20 ticks
    speed_angle = speed_vector_angle(unit)
    future_delta_x = Math.cos(speed_angle) * future_distance
    future_delta_y = Math.sin(speed_angle) * future_distance
    future_x = unit.x + future_delta_x
    future_y = unit.y + future_delta_y
    if future_x < game.rink_left
      future_x = game.rink_left + (game.rink_left - future_x)
    elsif future_x > game.rink_right
      future_x = game.rink_right - (future_x - game.rink_right)
    end
    if future_y < game.rink_top
      future_y = game.rink_top + (game.rink_top - future_y)
    elsif future_y > game.rink_bottom
      future_y = game.rink_bottom - (future_y - game.rink_bottom)
    end
    [future_x, future_y]
  end

  def speed_vector_angle(unit)
    Math.atan2(unit.speed_y, unit.speed_x)
  end

  # Calculates difference between angles a1 and a2.
  # @return Sighed value.
  #         Positive value corresponds clockwise direction from a1 to a2.
  def angles_diff(a1, a2)
    diff = a2 - a1
    while diff > Math::PI
      diff -= 2.0 * Math::PI
    end
    while diff < -Math::PI
      diff += 2.0 * Math::PI
    end
    diff
  end

  def speed_vector_angles_diff(unit1, unit2)
    angles_diff(speed_vector_angle(unit1), speed_vector_angle(unit2))
  end

  def unit_moves_in_opposite_direction?(unit, target)
    diff = speed_vector_angles_diff(unit, target)
    diff.abs > Math::PI/2
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

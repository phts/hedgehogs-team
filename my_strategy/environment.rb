require "./model/hockeyist_type"
require "./model/action_type"
require_relative "constants"
require_relative "utils"

class Environment

  FAST_TURN_ENOUGH_ANGLE = 0.5 * Math::PI / 180

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :move
  attr_reader :my_player
  attr_reader :opponent_player

  def update(me, world, game, move)
    @me = me
    @world = world
    @game = game
    @move = move
    @my_player = world.get_my_player
    @opponent_player = world.get_opponent_player
  end

  def debug(message = nil)
    puts "#{message}"
    puts "   #{me.teammate_index+1} x:#{me.x} y:#{me.y} a:#{me.angle}"
    puts "   speed_up:#{move.speed_up} turn:#{move.turn} action:#{move.action}"
  end

  def me_nearer_than?(value)
    Constants.opponent_on_the_left? ? (me.x > value) : (me.x < value)
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

  def hockeyist_by_id(id)
    world.hockeyists.select{ |h| h.id == id }.first
  end

  def reachable_unit?(unit)
    me.get_distance_to_unit(unit) <= Constants::REACH_DISTANCE &&
      Constants::REACH_ANGLES.include?(me.get_angle_to_unit(unit))
  end

  def reachable_opponent_hockeyist
    player_hockeyists(opponent_player.id).each do |h|
      return h if reachable_unit?(h)
    end
    nil
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

  def go_to_angle(angle)
    move.speed_up = 1.0
    fast_turn(angle)
    unless angle.abs < Math::PI/2
      # if moves from unit
      unless Utils.unit_speed(me) < 2
        # if me moves fast then stop and turn
        move.speed_up = -1.0
      end
    end
    unless my_hockeyists_own_puck?
      move.action = ActionType::TAKE_PUCK
    end
    try_to_knock_down_opponent
  end

  def go_to_unit(unit)
    go_to_angle(me.get_angle_to_unit(unit))
  end

  def go_to_moving_unit(unit)
    if Utils.unit_moves_in_opposite_direction?(me, unit)
      # if unit moves in an opposite direction to me
      angle_to_unit = if me.get_distance_to_unit(unit) > 100
                        # if unit is too far
                        # then calc angle to its future position to be able to take it fast
                        future_pos = future_position(unit)
                        me.get_angle_to(future_pos[0], future_pos[1])
                      else
                        me.get_angle_to_unit(unit)
                      end
    else
      angle_to_unit = me.get_angle_to_unit(unit)
    end
    go_to_angle(angle_to_unit)
  end

  def future_position(unit)
    future_distance = Utils.unit_speed(unit) * 20 # distance in 20 ticks
    speed_angle = Utils.speed_vector_angle(unit)
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

  def fast_turn(angle)
    if angle.abs < FAST_TURN_ENOUGH_ANGLE
      move.turn = angle
      return
    end
    move.turn = angle > 0 ? Math::PI : -Math::PI
  end

  def try_to_knock_down_opponent(always = false)
    h = reachable_opponent_hockeyist
    if h
      if always || h.get_angle_to_unit(me).abs < Math::PI/2
        # strike only if the opponent looks at me
        # otherwise strike can push him and his speed will be increased
        move.action = ActionType::STRIKE
        return
      end
      if world.puck.owner_hockeyist_id == h.id
        # if he owns the puck and stands back to me
        # then strike him with swinging to have higher change to knock him down
        move.action = ActionType::SWING
        return
      end
    end
  end

  def my_defenders_in_front_of_attacking_opponent(attacking)
    my_hockeyists = player_hockeyists(my_player.id)
    my_hockeyists.select{ |h| Utils.nearer_than?(attacking.x, h) }
  end

end

require "./model/hockeyist_type"
require "./model/action_type"
require_relative "constants"
require_relative "utils"

class Environment

  FAST_TURN_ENOUGH_ANGLE = Math::PI / 180

  attr_reader :me
  attr_reader :world
  attr_reader :move
  attr_reader :my_player
  attr_reader :opponent_player

  def update(me, world, move)
    @me = me
    @world = world
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

  # Returns a sorted array of nearest my hockeyists to unit.
  # First item - nearest hockeyist, last item - farthest hockeyist.
  def nearest_my_hockeyists_to_unit(unit)
    player_hockeyists(my_player.id).sort{ |h1, h2| h1.get_distance_to_unit(unit) <=> h2.get_distance_to_unit(unit) }
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

  def overtime?
    world.tick >= world.tick_count
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
    smart_turn(angle)
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
      angle_to_unit = if me.get_distance_to_unit(unit) > 250
                        # if unit is too far
                        # then calc angle to its future position to be able to take it fast
                        future_pos = Utils.future_position(unit, 5*Utils.unit_speed(unit))
                        me.get_angle_to(future_pos[0], future_pos[1])
                      else
                        me.get_angle_to_unit(unit)
                      end
    else
      angle_to_unit = me.get_angle_to_unit(unit)
    end
    go_to_angle(angle_to_unit)
  end

  def fast_turn(angle)
    if angle.abs < FAST_TURN_ENOUGH_ANGLE
      move.turn = angle
      return
    end
    move.turn = angle > 0 ? Math::PI : -Math::PI
  end

  def smart_turn(angle)
    fast_turn(angle)
    unless angle.abs < Math::PI/2
      # if moves from unit
      unless Utils.unit_speed(me) < 2
        # if me moves fast then stop and turn
        move.speed_up = -1.0
      end
    end
  end

  def try_to_knock_down_opponent(always = false)
    h = reachable_opponent_hockeyist
    if h
      if always || world.puck.owner_hockeyist_id != h.id || h.get_angle_to_unit(me).abs < Math::PI/2
        # strike only if the opponent with the puck looks at me
        # or if he doesn't own the puck in any direction
        # otherwise strike can push him and his speed will be increased
        move.action = ActionType::STRIKE
        return
      end
    end
  end

  def my_defenders_in_front_of_attacking_opponent(attacking)
    my_hockeyists = player_hockeyists(my_player.id)
    my_hockeyists.select{ |h| Utils.nearer_than?(attacking.x, h) }
  end

end

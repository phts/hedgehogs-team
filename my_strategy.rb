require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/hockeyist_state'
require './utils'

class MyStrategy
  include Utils

  ENOUGH_STRIKE_ANGLE = 0.5 * Math::PI / 180
  STRIKE_POSITION_FROM_MY_SIDE_X = 544

  def move(me, world, game, move)
    @me = me
    @world = world
    @game = game
    @movee = move
    @my_player = world.get_my_player

    if my_player.just_scored_goal || my_player.just_missed_goal
      # easter egg: when someone scored my hockeyists start having fun
      do_state :having_fun
      return
    end

    if me.state == HockeyistState::SWINGING
      move.action = ActionType::STRIKE
      return
    end

    if world.puck.owner_player_id == me.player_id
      if world.puck.owner_hockeyist_id == me.id
        do_state :holding
      else
        if near_section_xx.include?(world.puck.x)
          # if puck is on the near half
          do_state :defending
        else
          # if puck is on the far half
          do_state :supporting
        end
      end
    else
      if units_equal?(nearest_my_hockeyist_to_unit(world.puck), me)
        do_state :taking
      else
        do_state :defending
      end
    end
  end

  private

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :movee
  attr_reader :my_player

  attr_accessor :state
  attr_accessor :strike_position
  attr_accessor :in_strike_position

  def do_state(value)
    if value != state
      reset_method = :"reset_#{state}_state"
      if respond_to?(reset_method, true)
        send reset_method
      end
    end
    self.state = value
    send(value)
  end

  def reset_holding_state
    self.strike_position = nil
    self.in_strike_position = nil
  end

  def supporting
    opp = nearest_opponent_hockeyist_to_unit(world.puck)
    movee.speed_up = 1.0
    movee.turn = me.get_angle_to_unit(opp)
    movee.action = ActionType::NONE
    if reachable_unit?(opp)
      movee.action = ActionType::SWING
    end
  end

  def holding
    unless strike_position
      self.strike_position = calc_strike_position
    end
    go
  end

  def calc_strike_position
    pos = []
    top_strike_point_x = x_from_my_vertical_side(STRIKE_POSITION_FROM_MY_SIDE_X)
    top_strike_point_y = game.rink_top + 100
    bottom_strike_point_x = top_strike_point_x
    bottom_strike_point_y = game.rink_bottom - 100
    angle_to_top_strike_point = me.get_angle_to(top_strike_point_x, top_strike_point_y)
    angle_to_bottom_strike_point = me.get_angle_to(bottom_strike_point_x, bottom_strike_point_y)
    if (me_nearer_than?(STRIKE_POSITION_FROM_MY_SIDE_X))
      if angle_to_top_strike_point.abs < angle_to_bottom_strike_point.abs
        pos << [top_strike_point_x, top_strike_point_y]
      else
        pos << [bottom_strike_point_x, bottom_strike_point_y]
      end
    else
      pos << [x_from_my_vertical_side(300), my_net_center_y]
      if angle_to_top_strike_point.abs < angle_to_bottom_strike_point.abs
        pos << [bottom_strike_point_x, bottom_strike_point_y]
      else
        pos << [top_strike_point_x, top_strike_point_y]
      end
    end
    pos
  end

  def go
    movee.speed_up = 1.0
    if in_strike_position
      turn_to_net
      return
    end
    point = strike_position.first
    x = point[0]
    y = point[1]
    movee.turn = me.get_angle_to(x, y)
    if me.get_distance_to(x, y) < 100
      strike_position.shift
      if strike_position.empty?
        turn_to_net
      end
    end
  end

  def turn_to_net
    self.in_strike_position = true
    nety = opponent_net_center_y
    nety += (me.y < nety ? 0.46 : -0.46) * game.goal_net_height;
    ang_to_net = me.get_angle_to(opponent_net_center_x, nety)
    movee.turn = ang_to_net
    if ang_to_net.abs < ENOUGH_STRIKE_ANGLE
      movee.action = ActionType::SWING
    end
  end

  def taking
    movee.speed_up = 1.0
    movee.turn = me.get_angle_to_unit(world.puck)
    movee.action = ActionType::TAKE_PUCK
    try_to_knock_down_opponent
  end

  def defending
    defending_x = x_from_my_vertical_side(120)
    defending_y = my_net_center_y
    angle_to_defending = me.get_angle_to(defending_x, defending_y)

    movee.action = ActionType::TAKE_PUCK
    movee.turn = angle_to_defending
    movee.speed_up = 1.0

    distance = me.get_distance_to(defending_x, defending_y)
    if distance < 30
      movee.speed_up = 0
      if @speed_up_bak
        # stop sharply (set opposite speed up)
        if @speed_up_bak < 0
          movee.speed_up = 1.0
        else
          movee.speed_up = -1.0
        end
        if me.speed_x.abs < 1 && me.speed_y.abs < 1
          movee.speed_up = 0
        end
      end
      movee.turn = me.get_angle_to_unit(world.puck)
      if reachable_unit?(world.puck)
        movee.action = ActionType::STRIKE
      end
    elsif distance < 150
      if angle_to_defending.abs < Math::PI/2
        # if me looks at defending point
        movee.turn = angle_to_defending
        movee.speed_up = 0.5
      else
        # if me looks in a opposide side from defending point
        movee.turn = opposite_angle(angle_to_defending)
        movee.speed_up = -1.0
      end
      @speed_up_bak = movee.speed_up
    end
    try_to_knock_down_opponent
  end

  def try_to_knock_down_opponent
    if reachable_opponent_hockeyist
      movee.action = ActionType::STRIKE
    end
  end

  def having_fun
    # fight with my opponent's hockeyists
    opponent = nearest_opponent_hockeyist_to_unit(me)
    movee.turn = me.get_angle_to_unit(opponent)
    movee.speed_up = 1.0
    try_to_knock_down_opponent
  end

end

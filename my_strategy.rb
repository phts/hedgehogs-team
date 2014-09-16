require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/hockeyist_state'
require './constants'
require './utils'

class MyStrategy
  include Constants
  include Utils

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
          # if puck is on the far half
          do_state :supporting
        else
          # if puck is on the near half
          do_state :defending
        end
      end
    else
      if units_equal?(nearest_my_hockeyist_to_unit(world.puck), me)
        if world.puck.owner_hockeyist_id == -1
          # if nobody owns the puck
          do_state :picking_up
        else
          do_state :taking_away
        end
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
    if me.get_distance_to(defending_point_x, defending_point_y) < 100
      # if took the puck probably while defencing
      # then go to the opposide side where the opponent was from
      if in_top_section?(nearest_opponent_hockeyist_to_unit(me))
        # if nearest opponent in the top section then move down
        pos << [bottom_middle_point_x, bottom_middle_point_y]
        pos << [bottom_strike_point_x, bottom_strike_point_y]
      else
        # if nearest opponent in the bottom section then move up
        pos << [top_middle_point_x, top_middle_point_y]
        pos << [top_strike_point_x, top_strike_point_y]
      end
      return pos
    end
    angle_to_top_strike_point = me.get_angle_to(top_strike_point_x, top_strike_point_y)
    angle_to_bottom_strike_point = me.get_angle_to(bottom_strike_point_x, bottom_strike_point_y)
    if (me_nearer_than?(STRIKE_POINT_X_FROM_MY_SIDE))
      if angle_to_top_strike_point.abs < angle_to_bottom_strike_point.abs
        pos << [top_middle_point_x, top_middle_point_y]
        pos << [top_strike_point_x, top_strike_point_y]
      else
        pos << [bottom_middle_point_x, bottom_middle_point_y]
        pos << [bottom_strike_point_x, bottom_strike_point_y]
      end
    else
      if angle_to_top_strike_point.abs < angle_to_bottom_strike_point.abs
        pos << [top_near_point_x, top_near_point_y]
        pos << [bottom_middle_point_x, bottom_middle_point_y]
        pos << [bottom_strike_point_x, bottom_strike_point_y]
      else
        pos << [bottom_near_point_x, bottom_near_point_y]
        pos << [top_middle_point_x, top_middle_point_y]
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

  def picking_up
    movee.speed_up = 1.0
    movee.turn = me.get_angle_to_unit(world.puck)
    movee.action = ActionType::TAKE_PUCK
    try_to_knock_down_opponent
  end

  def taking_away
    movee.speed_up = 1.0
    movee.turn = me.get_angle_to_unit(world.puck)
    if reachable_unit?(world.puck)
      movee.action = ActionType::STRIKE
    end
    try_to_knock_down_opponent
  end

  def defending
    angle_to_defending = me.get_angle_to(defending_point_x, defending_point_y)

    movee.action = ActionType::TAKE_PUCK
    movee.turn = angle_to_defending
    movee.speed_up = 1.0

    distance = me.get_distance_to(defending_point_x, defending_point_y)
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
        movee.speed_up = 0.4
      else
        # if me looks in a opposide side from defending point
        movee.turn = opposite_angle(angle_to_defending)
        movee.speed_up = -0.6
      end
      @speed_up_bak = movee.speed_up
    end
    try_to_knock_down_opponent
  end

  def try_to_knock_down_opponent(always = false)
    h = reachable_opponent_hockeyist
    if h
      if always || h.get_angle_to_unit(me).abs < Math::PI/2 || world.puck.owner_hockeyist_id == h.id
        # strike only if the opponent looks at me or if he owns the puck (any directions)
        # otherwise strike can push him and his speed will be increased
        movee.action = ActionType::STRIKE
      end
    end
  end

  def having_fun
    movee.speed_up = 1.0
    if my_player.just_scored_goal
      # fight with teammates
      teammate = nearest_my_hockeyist_to_unit(me, me)
      movee.turn = me.get_angle_to_unit(teammate)
      if reachable_unit?(teammate)
        movee.action = ActionType::STRIKE
      end
    else
      # fight with opponent's hockeyists
      opponent = nearest_opponent_hockeyist_to_unit(me)
      movee.turn = me.get_angle_to_unit(opponent)
      try_to_knock_down_opponent(true)
    end
  end

end

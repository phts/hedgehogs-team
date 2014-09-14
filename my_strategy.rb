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

  def move(me, world, game, move)
    @me = me
    @world = world
    @game = game
    @movee = move

    if me.state == HockeyistState::SWINGING
      move.action = ActionType::STRIKE
      return
    end

    if world.puck.owner_player_id == me.player_id
      if world.puck.owner_hockeyist_id == me.id
        reset_defending_state
        do_state :holding
      else
        reset_holding_state
        if near_section_xx.include?(world.puck.x)
          # if puck is on the near half
          do_state :defending
        else
          # if puck is on the far half
          reset_defending_state
          do_state :supporting
        end
      end
    else
      reset_holding_state
      if units_equal?(nearest_my_hockeyist_to_unit(world.puck), me)
        reset_defending_state
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

  attr_accessor :state
  attr_accessor :strike_position
  attr_accessor :in_strike_position

  attr_accessor :in_defending_position
  attr_accessor :moving_direction_to_defence

  def do_state(value)
    self.state = value
    send(value)
  end

  def reset_holding_state
    self.strike_position = nil
    self.in_strike_position = nil
  end

  def reset_defending_state
    self.in_defending_position = false
    self.moving_direction_to_defence = nil
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
    do_state :going_to_strike_position
  end

  def going_to_strike_position
    unless strike_position
      if me_in_top_far_section? && me_look_at_bottom_far_corner?
        # TODO move to bottom far section center first
        self.strike_position = :top_center
      elsif me_in_bottom_far_section? && me_look_at_bottom_near_corner?
        # TODO move to bottom near section center first
        self.strike_position = :top_center
      elsif me_in_bottom_near_section? && me_look_up?
        # TODO move to top near section center first
        self.strike_position = :top_center
      elsif me_in_bottom_near_section? && me_look_back? ||
         me_in_top_near_section? && me_look_up?
        self.strike_position = :top_center
      elsif me_in_bottom_far_section? && me_look_at_top_far_corner?
        # TODO move to top far section center first
        self.strike_position = :bottom_center
      elsif me_in_top_far_section? && me_look_at_top_near_corner?
        # TODO move to top near section center first
        self.strike_position = :bottom_center
      elsif me_in_top_near_section? && me_look_down?
        # TODO move to bottom near section center first
        self.strike_position = :bottom_center
      elsif me_in_top_near_section? && me_look_back? ||
         me_in_bottom_near_section? && me_look_down?
        self.strike_position = :bottom_center
      else
        # Ususally on start when angle == 3.14
        self.strike_position = :top_center
      end
    end
    do_state :"going_to_#{strike_position}"
  end

  def going_to_top_center
    movee.speed_up = 1.0
    if in_strike_position
      do_state :turning_to_net
      return
    end
    centerx = rink_width/2
    centery = game.rink_top + 100
    movee.turn = me.get_angle_to(centerx, centery)
    if me.get_distance_to(centerx, centery) < 100
      do_state :turning_to_net
    end
  end

  def going_to_bottom_center
    movee.speed_up = 1.0
    if in_strike_position
      do_state :turning_to_net
      return
    end
    centerx = rink_width/2
    centery = game.rink_bottom - 100
    movee.turn = me.get_angle_to(centerx, centery)
    if me.get_distance_to(centerx, centery) < 100
      do_state :turning_to_net
    end
  end

  def turning_to_net
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
    defending_x = x_from_my_vertical_side(10)
    defending_y = my_net_center_y
    defending_y += (world.puck.y < defending_y ? 0.3 : -0.3) * game.goal_net_height;
    angle_to_defending = me.get_angle_to(defending_x, defending_y)
    opposite_angle_to_defending = opposite_angle(angle_to_defending)

    unless in_defending_position
      if moving_direction_to_defence.nil?
        # me_look_back? || me_in_far_section?
        movee.speed_up = 1.0
        movee.turn = angle_to_defending

        if me_look_forward?
          if me_look_up?
            if me_in_top_near_section?
              movee.speed_up = 1.0
              movee.turn = angle_to_defending
            elsif me_in_bottom_near_section?
              movee.turn = opposite_angle_to_defending
              movee.speed_up = -1.0
            end
          else
            if me_in_top_near_section?
              movee.speed_up = -1.0
              movee.turn = opposite_angle_to_defending
            elsif me_in_bottom_near_section?
              movee.speed_up = 1.0
              movee.turn = angle_to_defending
            end
          end
        end
        self.moving_direction_to_defence = movee.speed_up
      else
        if moving_direction_to_defence < 0
          movee.speed_up = -1.0
          movee.turn = opposite_angle_to_defending
        else
          movee.speed_up = 1.0
          movee.turn = angle_to_defending
        end
      end
    end
    movee.action = ActionType::TAKE_PUCK

    distance = me.get_distance_to(defending_x, defending_y)
    if distance < 40
      self.in_defending_position = true
      @moving_direction_to_defence_bak = moving_direction_to_defence unless moving_direction_to_defence.nil?
      self.moving_direction_to_defence = nil

      if @moving_direction_to_defence_bak
        if @moving_direction_to_defence_bak < 0
          movee.speed_up = 1.0
        else
          movee.speed_up = -1.0
        end
        if me.speed_x.abs < 1 && me.speed_y.abs < 1
          movee.speed_up = 0
        end
      else
        movee.speed_up = 0
      end
      movee.turn = me.get_angle_to_unit(world.puck)
      if reachable_unit?(world.puck)
        movee.action = ActionType::STRIKE
      end
    else
      self.in_defending_position = false
    end
    try_to_knock_down_opponent
  end

  def try_to_knock_down_opponent
    if reachable_opponent_hockeyist
      movee.action = ActionType::STRIKE
    end
  end

end

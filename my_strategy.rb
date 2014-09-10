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
        do_state :holding
      else
        self.strike_position = nil
        do_state :supporting
      end
    else
      self.strike_position = nil
      do_state :taking
    end
  end

  private

  attr_reader :me
  attr_reader :world
  attr_reader :game
  attr_reader :movee

  attr_accessor :state
  attr_accessor :strike_position

  def do_state(value)
    self.state = value
    send(value)
  end

  def supporting
    netx = opponent_net_center_x
    netx += opponent_on_the_left? ? 200 : -200
    nety = opponent_net_center_y
    nety += (world.puck.y < nety ? 0.5 : -0.5) * game.goal_net_height;
    movee.speed_up = 1.0

    ang_to_net = me.get_angle_to(netx, nety)
    movee.turn = ang_to_net
  end

  def holding
    do_state :going_to_strike_position
  end

  def going_to_strike_position
    unless strike_position
      if me_in_top_far_section? || me_in_top_near_section?
        # if taken on the bottom section then go to bottom center
        self.strike_position = :top_center
      elsif me_in_bottom_far_section? || me_in_bottom_near_section?
        # if taken on the top section then go to top center
        self.strike_position = :bottom_center
      end
    end
    do_state :"going_to_#{strike_position}"
  end

  def going_to_top_center
    centerx = rink_width/2
    centery = game.rink_top + 100
    movee.speed_up = 1.0
    movee.turn = me.get_angle_to(centerx, centery)
    if me.get_distance_to(centerx, centery) < 100
      do_state :turning_to_net
    end
  end

  def going_to_bottom_center
    centerx = rink_width/2
    centery = game.rink_bottom - 100
    movee.speed_up = 1.0
    movee.turn = me.get_angle_to(centerx, centery)
    if me.get_distance_to(centerx, centery) < 100
      do_state :turning_to_net
    end
  end

  def turning_to_net
    nety = opponent_net_center_y
    nety += (me.y < nety ? 0.5 : -0.5) * game.goal_net_height;
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
  end

end
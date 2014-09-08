require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/hockeyist_state'

class MyStrategy
  # @param [Hockeyist] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, move)
    if me.state == HockeyistState::SWINGING
      move.action = ActionType::STRIKE
      return
    end

    puck = world.puck
    if puck.owner_player_id == me.player_id
      if puck.owner_hockeyist_id == me.id
        opponent = world.get_opponent_player
        netx = 0.5 * (opponent.net_left + opponent.net_right)
        nety = 0.5 * (opponent.net_top + opponent.net_bottom)
        nety += (me.y < nety ? 0.5 : -0.5) * game.goal_net_height;
        ang_to_net = me.get_angle_to(netx, nety)
        move.turn = ang_to_net
        if ang_to_net.abs < 1.0 * Math::PI / 180
          move.action = ActionType::SWING
        end
      end
    else
      move.speed_up = 1.0
      move.turn = me.get_angle_to_unit(puck)
      move.action = ActionType::TAKE_PUCK
    end
  end
end

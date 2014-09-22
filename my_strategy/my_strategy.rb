require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/hockeyist_state'
require_relative 'environment'
require_relative 'state_machine'
require_relative 'constants'
require_relative 'utils'

class MyStrategy

  def initialize
    @env = Environment.new
    @state_machine = StateMachine.new
  end

  def move(me, world, game, move)
    env.update(me, world, game, move)
    Constants.init(env)

    if env.my_player.just_scored_goal || env.my_player.just_missed_goal
      # easter egg: when someone scored my hockeyists start having fun
      do_state :having_fun
      return
    end

    if env.me.state == HockeyistState::SWINGING
      move.action = ActionType::STRIKE
      return
    end

    if env.losing? && env.game_ends_in_less_than?(1000)
      # when losing and game is almost ended
      # then turn on "Panic Mode"
      $panic_mode = true
    end
    if env.winning?
      $panic_mode = false
    end

    if env.my_hockeyists_own_puck?
      # if my hockeyists own the puck
      if world.puck.owner_hockeyist_id == env.me.id
        # if me owns the puck
        do_state :holding
      else
        # if my teammate owns the puck
        if env.panic_mode?
          if Utils.on_my_half?(world.puck)
            # if the puck is on my half
            do_state :supporting
          else
            # if the puck is on opponent's half
            do_state :clearing_the_net
          end
        else
          if Utils.on_my_half?(world.puck)
            # if the puck is on my half
            do_state :supporting
          else
            # if the puck is on opponent's half
            do_state :defending
          end
        end
      end
    else
      # if nobody or opponent hockeyists own the puck
      if Utils.units_equal?(env.nearest_my_hockeyist_to_unit(world.puck), me)
        # if me is closer to the puck than my teammates
        if world.puck.owner_hockeyist_id == -1
          # if nobody owns the puck
          do_state :picking_up
        else
          # if opponent hockeyists own the puck
          do_state :taking_away
        end
      else
        # if my teammates are closer to the puck than me
        if env.panic_mode?
          do_state :supporting
        else
          if world.puck.owner_hockeyist_id == -1
            # nobody
            do_state :defending
          else
            # opponent
            h = env.hockeyist_by_id(world.puck.owner_hockeyist_id)
            if env.my_defenders_in_front_of_attacking_opponent(h).count <= 1
              # if only one my hockeyist is in front of attacking opponent
              do_state :taking_away
            else
              do_state :defending
            end
          end
        end
      end
    end
  end

  private

  attr_reader :env

  def do_state(value)
    @state_machine.perform(value, env)
  end

end

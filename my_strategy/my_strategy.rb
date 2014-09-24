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

    @state_machine.perform(env)
  end

  private

  attr_reader :env

end

require_relative "clearing_the_net_state"
require_relative "defending_state"
require_relative "having_fun_state"
require_relative "holding_state"
require_relative "picking_up_state"
require_relative "supporting_state"
require_relative "taking_away_state"

class StateMachine

  def initialize
    @state_to_object = {}
    classes = State.constants.select{ |c| c != :Base && State.const_get(c).is_a?(Class) }.map { |c| State.const_get(c) }
    classes.each do |cl|
      @state_to_object[cl.state_name] = cl.new
    end
  end

  def perform(new_state, env)
    unless new_state == state
      state_to_object[state].reset if state
      @state = new_state
    end
    state_to_object[new_state].perform_state(env)
  end

  private

  attr_reader :state
  attr_reader :state_to_object

end

require_relative "having_fun_state"
require_relative "clearing_the_net_state"
require_relative "defending_state"
require_relative "holding_state"
require_relative "picking_up_state"
require_relative "supporting_state"
require_relative "taking_away_state"

class StateMachine

  DEFAULT_STATE = :picking_up

  def init(team_size)
    return if @state_to_object
    @state_to_object = {}
    classes = State.constants.select{ |c| c != :Base && State.const_get(c).is_a?(Class) }.map { |c| State.const_get(c) }
    classes.each do |cl|
      @state_to_object[cl.state_name] = cl.new(team_size)
    end
  end

  def perform(env)
    state_to_object.each do |name, st|
      if st.should_perform?(env)
        perform_state(name, env)
        return
      end
    end
    puts "WARNING: no states performed: #{env.inspect}"
    perform_state(DEFAULT_STATE, env)
  end

  private

  attr_reader :state
  attr_reader :state_to_object

  def perform_state(new_state, env)
    unless new_state == state
      state_to_object[state].reset(env) if state
      @state = new_state
    end
    state_to_object[new_state].perform_state(env)
  end

end

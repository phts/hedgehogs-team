Dir[File.join(File.dirname(__FILE__), '*_state.rb')].each{ |file| require_relative File.basename(file) }

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

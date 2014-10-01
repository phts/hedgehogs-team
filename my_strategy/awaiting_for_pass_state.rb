require_relative "base_state"

module State
  class AwaitingForPass < Base

    def self.state_name
      :awaiting_for_pass
    end

    protected

    def perform_for_two?
      env.me_awaiting_for_pass?
    end

    def perform
      a = me.get_angle_to_unit(world.puck)
      env.smart_turn(a)
    end

  end
end

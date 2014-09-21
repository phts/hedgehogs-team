require './model/action_type'
require_relative "base_state"

module State
  class TakingAway < Base

    def self.state_name
      :taking_away
    end

    def perform
      env.go_to_moving_unit(world.puck)
      if env.reachable_unit?(world.puck)
        move.action = ActionType::STRIKE
      end
    end

  end
end

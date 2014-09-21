require_relative "base_state"

module State
  class Supporting < Base

    def self.state_name
      :supporting
    end

    def perform
      opp = env.nearest_opponent_hockeyist_to_unit(world.puck)
      env.go_to_moving_unit(opp)
    end

  end
end

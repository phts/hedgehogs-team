require_relative "base_state"
require_relative "constants"

module State
  class ClearingTheNet < Base

    def self.state_name
      :clearing_the_net
    end

    def perform
      opp = env.nearest_opponent_hockeyist_to(Constants.opponent_net_center_x, Constants.opponent_net_center_y)
      env.go_to_unit(opp)
    end

  end
end

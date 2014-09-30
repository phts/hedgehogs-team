require_relative "base_state"
require_relative "constants"

module State
  class ClearingTheNet < Base

    def self.state_name
      :clearing_the_net
    end

    def perform_for_two?
      if env.my_hockeyists_own_puck?
        # if my hockeyists own the puck
        unless world.puck.owner_hockeyist_id == me.id
          # if my teammate owns the puck
          if env.panic_mode?
            if Utils.on_opponent_half?(world.puck)
              return true
            end
          end
        end
      end
      false
    end

    def perform
      opp = env.nearest_opponent_hockeyist_to(Constants.opponent_net_center_x, Constants.opponent_net_center_y)
      env.go_to_unit(opp)
    end

  end
end

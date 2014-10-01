require_relative "base_state"
require_relative "constants"
require_relative "utils"

module State
  class Supporting < Base

    def self.state_name
      :supporting
    end

    protected

    def perform_for_two?
      if env.my_hockeyists_own_puck?
        # if my hockeyists own the puck
        unless world.puck.owner_hockeyist_id == me.id
          # if my teammate owns the puck
          if Utils.on_my_half?(world.puck)
            return true
          end
        end
      else
        # if nobody or opponent hockeyists own the puck
        unless Utils.units_equal?(env.nearest_my_hockeyist_to_unit(world.puck), me)
          # if my teammate is closer to the puck than me
          if env.panic_mode?
            return true
          end
        end
      end
      false
    end

    def perform_for_three?
      if env.my_hockeyists_own_puck?
        # if my hockeyists own the puck
        unless world.puck.owner_hockeyist_id == me.id
          # if my teammate owns the puck
          if Utils.on_my_half?(world.puck)
            return true
          end
          if !Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck).last)
            return true
          end
        end
      else
        # if nobody or opponent hockeyists own the puck
        unless Utils.units_equal?(env.nearest_my_hockeyist_to_unit(world.puck), me)
          # if my teammate is closer to the puck than me
          if env.panic_mode?
            return true
          end
          if !Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck).last)
            return true
          end
        end
      end
      false
    end

    def perform
      opp = env.nearest_opponent_hockeyist_to_unit(world.puck)
      env.go_to_moving_unit(opp)
    end

  end
end

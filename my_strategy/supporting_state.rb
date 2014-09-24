require_relative "base_state"

module State
  class Supporting < Base

    def self.state_name
      :supporting
    end

    def should_perform?(env)
      if env.my_hockeyists_own_puck?
        # if my hockeyists own the puck
        unless env.world.puck.owner_hockeyist_id == env.me.id
          # if my teammate owns the puck
          if Utils.on_my_half?(env.world.puck)
            return true
          end
        end
      else
        # if nobody or opponent hockeyists own the puck
        unless Utils.units_equal?(env.nearest_my_hockeyist_to_unit(env.world.puck), env.me)
          # if my teammates are closer to the puck than me
          if env.panic_mode?
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

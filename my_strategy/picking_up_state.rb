require_relative "base_state"

module State
  class PickingUp < Base

    def self.state_name
      :picking_up
    end

    def should_perform?(env)
      unless env.my_hockeyists_own_puck?
        # if nobody or opponent hockeyists own the puck
        if Utils.units_equal?(env.nearest_my_hockeyist_to_unit(env.world.puck), env.me)
          # if me is closer to the puck than my teammates
          if env.world.puck.owner_hockeyist_id == -1
            # if nobody owns the puck
            return true
          else
            # if opponent hockeyists own the puck
            if Utils.on_opponent_half?(env.world.puck)
              return true
            end
          end
        end
      end
      false
    end

    def perform
      env.go_to_moving_unit(world.puck)
    end

  end
end

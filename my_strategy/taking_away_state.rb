require './model/action_type'
require_relative "base_state"

module State
  class TakingAway < Base

    def self.state_name
      :taking_away
    end

    def should_perform?(env)
      unless env.my_hockeyists_own_puck?
        # if nobody or opponent hockeyists own the puck
        if Utils.units_equal?(env.nearest_my_hockeyist_to_unit(env.world.puck), env.me)
          # if me is closer to the puck than my teammates
          unless env.world.puck.owner_hockeyist_id == -1
            # if opponent hockeyists own the puck
            if Utils.on_my_half?(env.world.puck)
              return true
            end
          end
        else
          # if my teammate is closer to the puck than me
          unless env.panic_mode?
            unless env.world.puck.owner_hockeyist_id == -1
              # opponent
              h = env.hockeyist_by_id(env.world.puck.owner_hockeyist_id)
              if env.my_defenders_in_front_of_attacking_opponent(h).count <= 1
                # if only one my hockeyist is in front of attacking opponent
                return true
              end
            end
          end
        end
      end
      false
    end

    def perform
      env.go_to_moving_unit(world.puck)
      if env.reachable_unit?(world.puck)
        move.action = ActionType::STRIKE
      end
    end

  end
end

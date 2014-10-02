require_relative "base_state"
require_relative "constants"
require_relative "utils"

module State
  class DefendingCenter < Defending

    def self.state_name
      :defending_center
    end

    def self.defending_point_x
      $defending_center_point_x ||= Utils.x_from_my_vertical_side(400)
    end

    def self.defending_point_y
      $defending_center_point_y ||= Constants.my_net_center_y
    end

    protected

    def perform_for_two?
      false
    end

    def perform_for_three?
      if env.my_hockeyists_own_puck?
        # if my hockeyists own the puck
        unless world.puck.owner_hockeyist_id == me.id
          # if my teammate owns the puck
          unless env.panic_mode?
            unless Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck).last)
              # me not last (last is defending the net)
              if Utils.on_opponent_half?(world.puck)
                return true
              end
            end
          end
        end
      else
        # if nobody or opponent hockeyists own the puck
        unless Utils.units_equal?(env.nearest_my_hockeyist_to_unit(world.puck), me)
          # if my teammate is closer to the puck than me
          unless env.panic_mode?
            if world.puck.owner_hockeyist_id == -1
              # nobody
              if Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck)[1])
                return true
              end
            else
              # opponent
              if Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck)[1])
                h = env.hockeyist_by_id(world.puck.owner_hockeyist_id)
                unless env.my_defenders_in_front_of_attacking_opponent(h).count <= 2
                  # me and net defender in front of attacking opponent
                  return true
                end
              end
            end
          end
        end
      end
      false
    end

  end
end

require_relative "base_state"
require_relative "constants"
require_relative "utils"

module State
  class Defending < Base

    def self.state_name
      :defending
    end

    def self.defending_point_x
      $defending_point_x ||= Utils.x_from_my_vertical_side(120)
    end

    def self.defending_point_y
      $defending_point_y ||= Constants.my_net_center_y
    end

    def perform_for_two?
      if env.my_hockeyists_own_puck?
        # if my hockeyists own the puck
        unless world.puck.owner_hockeyist_id == me.id
          # if my teammate owns the puck
          unless env.panic_mode?
            if Utils.on_opponent_half?(world.puck)
              return true
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
              return true
            else
              # opponent
              h = env.hockeyist_by_id(world.puck.owner_hockeyist_id)
              unless env.my_defenders_in_front_of_attacking_opponent(h).count <= 1
                return true
              end
            end
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
          unless env.panic_mode?
            if Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck).last)
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
              if Utils.units_equal?(me, env.nearest_my_hockeyists_to_unit(world.puck).last)
                return true
              end
            else
              # opponent
              h = env.hockeyist_by_id(world.puck.owner_hockeyist_id)
              unless env.my_defenders_in_front_of_attacking_opponent(h).count <= 1
                return true
              end
            end
          end
        end
      end
      false
    end

    def perform
      angle_to_defending = me.get_angle_to(self.class.defending_point_x, self.class.defending_point_y)
      env.go_to_angle(angle_to_defending)

      distance = me.get_distance_to(self.class.defending_point_x, self.class.defending_point_y)
      if distance < 30
        move.speed_up = 0
        if @speed_up_bak
          # stop sharply (set opposite speed up)
          if @speed_up_bak < 0
            move.speed_up = 1.0
          else
            move.speed_up = -1.0
          end
          if Utils.unit_speed(me) < 1
            move.speed_up = 0
          end
        end
        move.turn = me.get_angle_to_unit(world.puck)
        if env.reachable_unit?(world.puck)
          move.action = ActionType::STRIKE
        end
      elsif distance < 200
        if angle_to_defending.abs < Math::PI/2
          # if me looks at defending point
          move.turn = angle_to_defending
          move.speed_up = 0.4
        else
          # if me looks in a opposide side from defending point
          move.turn = Utils.opposite_angle(angle_to_defending)
          move.speed_up = -0.6
        end
        @speed_up_bak = move.speed_up
      end
      env.try_to_knock_down_opponent
    end

  end
end

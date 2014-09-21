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
      elsif distance < 150
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

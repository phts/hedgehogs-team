require './model/action_type'
require_relative "base_state"
require_relative "constants"
require_relative "utils"
require_relative "defending_state"

module State
  class Holding < Base

    ENOUGH_STRIKE_ANGLE = 0.5 * Math::PI / 180

    STRIKE_POINT_X_FROM_MY_SIDE = 700
    STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE = 150

    def self.state_name
      :holding
    end

    def perform
      if Utils.on_opponent_half?(me) && env.opponent_hockeyists_nearer_to_unit_than(me, 120).size > 1
        # if too many opponent hockeyists near me on opponent's side
        teammate = env.nearest_my_hockeyist_to_unit(me, me)
        a = me.get_angle_to_unit(teammate)
        if a.abs < Math::PI/2
          # if me looks at my teammate
          if a.abs < Constants.enough_pass_angle
            move.pass_angle = a
            move.pass_power = 1.0
            move.action = ActionType::PASS
          else
            env.fast_turn(a)
          end
          return
        end
      end
      unless strike_position
        self.strike_position = calc_strike_position
      end
      go_to_strike_position
    end

    def reset
      self.strike_position = nil
      self.in_strike_position = nil
    end

    private

    attr_accessor :strike_position
    attr_accessor :in_strike_position

    def calc_strike_position
      pos = []
      if me.get_distance_to(Defending.defending_point_x, Defending.defending_point_y) < 100
        # if took the puck probably while defencing
        # then go to the opposide side where the opponent was from
        if Utils.on_top_half?(env.nearest_opponent_hockeyist_to_unit(me))
          # if nearest opponent in the top section then move down
          pos << [bottom_middle_point_x, bottom_middle_point_y]
          pos << [bottom_strike_point_x, bottom_strike_point_y]
        else
          # if nearest opponent in the bottom section then move up
          pos << [top_middle_point_x, top_middle_point_y]
          pos << [top_strike_point_x, top_strike_point_y]
        end
        return pos
      end
      angle_to_top_strike_point = me.get_angle_to(top_strike_point_x, top_strike_point_y)
      angle_to_bottom_strike_point = me.get_angle_to(bottom_strike_point_x, bottom_strike_point_y)
      if (env.me_nearer_than?(STRIKE_POINT_X_FROM_MY_SIDE))
        if angle_to_top_strike_point.abs < angle_to_bottom_strike_point.abs
          pos << [top_middle_point_x, top_middle_point_y]
          pos << [top_strike_point_x, top_strike_point_y]
        else
          pos << [bottom_middle_point_x, bottom_middle_point_y]
          pos << [bottom_strike_point_x, bottom_strike_point_y]
        end
      else
        if angle_to_top_strike_point.abs < angle_to_bottom_strike_point.abs
          pos << [top_near_point_x, top_near_point_y]
          pos << [bottom_middle_point_x, bottom_middle_point_y]
          pos << [bottom_strike_point_x, bottom_strike_point_y]
        else
          pos << [bottom_near_point_x, bottom_near_point_y]
          pos << [top_middle_point_x, top_middle_point_y]
          pos << [top_strike_point_x, top_strike_point_y]
        end
      end
      pos
    end

    def go_to_strike_position
      move.speed_up = 1.0
      if in_strike_position
        turn_to_net
        return
      end
      point = strike_position.first
      x = point[0]
      y = point[1]
      move.turn = me.get_angle_to(x, y)
      if me.get_distance_to(x, y) < 100
        strike_position.shift
        if strike_position.empty?
          turn_to_net
        end
      end
    end

    def turn_to_net
      self.in_strike_position = true
      nety = Constants.opponent_net_center_y
      nety += (Utils.on_top_half?(me) ? 0.46 : -0.46) * game.goal_net_height;
      ang_to_net = me.get_angle_to(Constants.opponent_net_center_x, nety)
      env.fast_turn(ang_to_net)
      if ang_to_net.abs < ENOUGH_STRIKE_ANGLE
        move.action = ActionType::SWING
      end
    end

    def top_strike_point_x
      $top_strike_point_x ||= Utils.x_from_my_vertical_side(STRIKE_POINT_X_FROM_MY_SIDE)
    end

    def top_strike_point_y
      $top_strike_point_y ||= game.rink_top + STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE
    end

    alias_method :bottom_strike_point_x, :top_strike_point_x

    def bottom_strike_point_y
      $bottom_strike_point_y ||= game.rink_bottom - STRIKE_POINT_Y_FROM_HORIZONTAL_SIDE
    end

    def top_middle_point_x
      Constants.rink_center_x
    end

    alias_method :top_middle_point_y, :top_strike_point_y
    alias_method :bottom_middle_point_x, :top_middle_point_x
    alias_method :bottom_middle_point_y, :bottom_strike_point_y

    def top_near_point_x
      $top_near_point_x ||= Utils.x_from_my_vertical_side(400)
    end

    def top_near_point_y
      Constants.my_net_center_y
    end

    alias_method :bottom_near_point_x, :top_near_point_x
    alias_method :bottom_near_point_y, :top_near_point_y

  end
end

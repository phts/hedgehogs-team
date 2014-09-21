require_relative 'constants'

module Utils
  class << self

    def in_top_section?(unit)
      unit.y <= Constants.rink_center_y
    end

    def in_right_section?(unit)
      unit.x >= Constants.rink_center_x
    end

    def in_left_section?(unit)
      unit.x <= Constants.rink_center_x
    end

    def in_near_section?(unit)
      Constants.opponent_on_the_left? ? in_right_section?(unit) : in_left_section?(unit)
    end

    def in_far_section?(unit)
      Constants.opponent_on_the_left? ? in_left_section?(unit) : in_right_section?(unit)
    end

    def x_from_my_vertical_side(value)
      Constants.my_net_center_x + (Constants.opponent_on_the_left? ? -value : value)
    end

    def opposite_angle(angle)
      return Math::PI if angle == 0
      return 0 if angle.abs == Math::PI
      angle < 0 ? angle+Math::PI : angle-Math::PI
    end

    def units_equal?(u1, u2)
      u1.id == u2.id
    end

    def unit_speed(unit)
      Math::sqrt(unit.speed_x**2 + unit.speed_y**2)
    end

    def speed_vector_angle(unit)
      Math.atan2(unit.speed_y, unit.speed_x)
    end

    # Calculates difference between angles a1 and a2.
    # @return Sighed value.
    #         Positive value corresponds clockwise direction from a1 to a2.
    def angles_diff(a1, a2)
      diff = a2 - a1
      while diff > Math::PI
        diff -= 2.0 * Math::PI
      end
      while diff < -Math::PI
        diff += 2.0 * Math::PI
      end
      diff
    end

    def speed_vector_angles_diff(unit1, unit2)
      angles_diff(speed_vector_angle(unit1), speed_vector_angle(unit2))
    end

    def unit_moves_in_opposite_direction?(unit, target)
      diff = speed_vector_angles_diff(unit, target)
      diff.abs > Math::PI/2
    end

  end
end

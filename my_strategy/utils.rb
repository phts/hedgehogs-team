require_relative 'constants'

module Utils
  class << self

    def right_than?(x, unit)
      unit.x >= x
    end

    def left_than?(x, unit)
      unit.x <= x
    end

    def nearer_than?(x, unit)
      Constants.opponent_on_the_left? ? right_than?(x, unit) : left_than?(x, unit)
    end

    def on_top_half?(unit)
      unit.y <= Constants.rink_center_y
    end

    def on_right_half?(unit)
      right_than?(Constants.rink_center_x, unit)
    end

    def on_left_half?(unit)
      left_than?(Constants.rink_center_x, unit)
    end

    def on_my_half?(unit)
      Constants.opponent_on_the_left? ? on_right_half?(unit) : on_left_half?(unit)
    end

    def on_opponent_half?(unit)
      Constants.opponent_on_the_left? ? on_left_half?(unit) : on_right_half?(unit)
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

class Constants

  REACH_DISTANCE = 120 # rules (p.13)
  REACH_ANGLES = ((-Math::PI/12)..(Math::PI/12)) # rules (p.13)

  class << self

    def init(env)
      return if $constants_initialized
      $rink_center_x = (env.game.rink_right+env.game.rink_left) * 0.5
      $rink_center_y = (env.game.rink_bottom+env.game.rink_top) * 0.5
      $opponent_on_the_left = env.opponent_player.net_left < rink_center_x
      $opponent_net_center_x = opponent_on_the_left? ? env.opponent_player.net_right : env.opponent_player.net_left
      $opponent_net_center_y = 0.5 * (env.opponent_player.net_top + env.opponent_player.net_bottom)
      $my_net_center_x = opponent_on_the_left? ? env.my_player.net_left : env.my_player.net_right
      $my_net_center_y = 0.5 * (env.my_player.net_top + env.my_player.net_bottom)
      $enough_pass_angle = 0.5 * env.game.pass_sector
      $constants_initialized = true
    end

    def opponent_on_the_left?
      $opponent_on_the_left
    end

    def opponent_net_center_x
      $opponent_net_center_x
    end

    def opponent_net_center_y
      $opponent_net_center_y
    end

    def my_net_center_x
      $my_net_center_x
    end

    def my_net_center_y
      $my_net_center_y
    end

    def rink_center_x
      $rink_center_x
    end

    def rink_center_y
      $rink_center_y
    end

    def enough_pass_angle
      $enough_pass_angle
    end

  end
end

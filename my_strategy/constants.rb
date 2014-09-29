class Constants

  REACH_DISTANCE = 120 # rules (p.13)
  REACH_ANGLES = ((-Math::PI/12)..(Math::PI/12)) # rules (p.13)

  METHODS = [
              :game,
              :rink_center_x,
              :rink_center_y,
              :opponent_net_center_x,
              :opponent_net_center_y,
              :my_net_center_x,
              :my_net_center_y,
              :enough_pass_angle,
            ]

  BOOLEAN_METHODS = [
                      :opponent_on_the_left,
                      :three_by_three,
                    ]

  METHODS.each do |m|
    instance_eval %Q{
      def #{m}
        $#{m}
      end
    }
  end

  BOOLEAN_METHODS.each do |m|
    instance_eval %Q{
      def #{m}?
        $#{m}
      end
    }
  end

  class << self

    def init(game, env)
      return if $constants_initialized
      $constants_initialized = true
      $game = game
      $rink_center_x = (game.rink_right+game.rink_left) * 0.5
      $rink_center_y = (game.rink_bottom+game.rink_top) * 0.5
      $opponent_on_the_left = env.opponent_player.net_left < rink_center_x
      $opponent_net_center_x = opponent_on_the_left? ? env.opponent_player.net_right : env.opponent_player.net_left
      $opponent_net_center_y = 0.5 * (env.opponent_player.net_top + env.opponent_player.net_bottom)
      $my_net_center_x = opponent_on_the_left? ? env.my_player.net_left : env.my_player.net_right
      $my_net_center_y = 0.5 * (env.my_player.net_top + env.my_player.net_bottom)
      $enough_pass_angle = 0.5 * game.pass_sector
      $three_by_three = env.world.hockeyists.size >= 8
    end

  end
end

require './model/action_type'
require_relative "base_state"

module State
  class HavingFun < Base

    def self.state_name
      :having_fun
    end

    def perform_for_two?
      env.my_player.just_scored_goal || env.my_player.just_missed_goal
    end

    def perform
      move.speed_up = 1.0
      if env.my_player.just_scored_goal
        # fight with teammates
        teammate = env.nearest_my_hockeyist_to_unit(me, me)
        move.turn = me.get_angle_to_unit(teammate)
        if env.reachable_unit?(teammate)
          move.action = ActionType::STRIKE
        end
      else
        # fight with opponent's hockeyists
        opponent = env.nearest_opponent_hockeyist_to_unit(me)
        move.turn = me.get_angle_to_unit(opponent)
        env.try_to_knock_down_opponent(true)
      end
    end

  end
end

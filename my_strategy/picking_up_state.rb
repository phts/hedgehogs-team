require_relative "base_state"

module State
  class PickingUp < Base

    def self.state_name
      :picking_up
    end

    def perform
      env.go_to_moving_unit(world.puck)
    end

  end
end

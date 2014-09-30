module State
  class Base

    TEAM_SIZE_TO_SHOULD_PERFORM_METHOD = {
                                           2 => :perform_for_two?,
                                           3 => :perform_for_three?,
                                           6 => :perform_for_six?,
                                         }

    def self.state_name
      raise "Should be overriden"
    end

    def initialize(team_size)
      @should_perform_method = TEAM_SIZE_TO_SHOULD_PERFORM_METHOD[team_size]
    end

    def perform_state(env)
      @env = env
      @me = @env.me
      @world = @env.world
      @move = @env.move
      perform
    end

    def should_perform?(env)
      send(@should_perform_method, env)
    end

    def reset; end

    protected

    def perform_for_two?(env)
      raise "Should be overriden"
    end

    def perform_for_three?(env)
      perform_for_two?(env)
    end

    def perform_for_six?(env)
      perform_for_three?(env)
    end

    def perform; end

    attr_reader :env
    attr_reader :me
    attr_reader :world
    attr_reader :move

  end
end

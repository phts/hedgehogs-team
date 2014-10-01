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
      store_env(env)
      perform
    end

    def should_perform?(env)
      store_env(env)
      send(@should_perform_method)
    end

    def reset(env); end

    protected

    def perform_for_two?
      raise "Should be overriden"
    end

    def perform_for_three?
      perform_for_two?
    end

    def perform_for_six?
      perform_for_three?
    end

    def perform; end

    attr_reader :env
    attr_reader :me
    attr_reader :world
    attr_reader :move

    private

    def store_env(env)
      @env = env
      @me = @env.me
      @world = @env.world
      @move = @env.move
    end

  end
end

module State
  class Base

    def self.state_name
      raise "Should be overriden"
    end

    def perform_state(env)
      @env = env
      @me = @env.me
      @world = @env.world
      @move = @env.move
      perform
    end

    def should_perform?(env)
      raise "Should be overriden"
    end

    def reset; end

    protected

    def perform; end

    attr_reader :env
    attr_reader :me
    attr_reader :world
    attr_reader :move

  end
end

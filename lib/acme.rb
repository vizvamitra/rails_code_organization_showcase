module Acme
  Error = Class.new(StandardError)
  ClientError = Class.new(Error)
  ServerError = Class.new(Error)
  AuthenticationError = Class.new(ClientError)

  class << self
    def configure(&block)
      yield(config)
    end

    def config
      @config ||= Configuration.new
    end
  end
end

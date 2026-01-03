module Acme
  class Configuration
    attr_accessor :base_url, :retry_limit

    def initialize
      @base_url = "https://api.acme.com"
      @retry_limit = 3
    end

    def to_h
      { base_url:, retry_limit: }
    end
  end
end

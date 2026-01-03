module Acme
  class HttpClient
    Response = Data.define(:status, :body, :headers)

    def initialize(base_url: Acme.config.base_url)
      @base_url = base_url
    end

    def request(verb, path, params = {}, headers = {})
      connection
        .send(verb, path, params, headers)
        .then { |raw_response| parse(raw_response) }
    end

    private

    attr_reader :base_url

    def connection
      Faraday.new(url: base_url) do |builder|
        builder.request :json
        builder.response :json
      end
    end

    def parse(raw_response)
      raw_response.to_hash => {status:, body:, response_headers: headers}

      case status
      when 200..299 then Response.new(status:, body:, headers:)
      when 401 then raise AuthenticationError.new(error_message(status, body))
      when 400, 402..499 then raise ClientError.new(error_message(status, body))
      when 500..599 then raise ServerError.new(error_message(status, body))
      end
    end

    def error_message(status, body)
      error = case body
        when String then body
        when Hash then body["error"] || body["message"]
        else nil
      end

      "[HTTP #{status}] #{error || 'Unknown error'}"
    end
  end
end

module Acme
  class ApiClient
    MAX_LIMIT = 1000

    def initialize(retry_limit: Acme.config.retry_limit,
                   http_client: HttpClient.new)
      @retry_limit = retry_limit
      @http_client = http_client
    end

    def get_identity(access_token:)
      get('/me', access_token:)['data']
    end

    def get_pages(access_token:, limit: 100)
      limit = limit.clamp(1, MAX_LIMIT)
      get_collection('/pages', limit:, access_token:)
    end

    private

    attr_reader :retry_limit, :http_client

    def get(path, params = {})
      request(:get, path, params)
    end

    def get_collection(path, params = {})
      paginated { get(path, params) }
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def request(verb, path, params)
      access_token = params.delete(:access_token)

      with_retry do
        http_client.request(verb, path, params, headers(access_token)).body
      end
    end

    def with_retry(retries = 0)
      yield
    rescue ServerError => e
      retries += 1
      retry if retries < retry_limit
      raise e
    end

    def paginated
      Enumerator.new do |yielder|
        response = yield
        Array(response['data']).each { |i| yielder << i }

        while (next_page = response.dig('meta', 'next_page'))
          response = get(next_page)
          Array(response['data']).each { |i| yielder << i }
        end
      end
    end

    def headers(access_token)
      { "Authorization" => "Bearer #{access_token}" }
    end
  end
end

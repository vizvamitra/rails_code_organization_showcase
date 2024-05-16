# frozen_string_literal: true

module Acme
  # A wrapper over AcmeSDK API client that provides logging, metrics,
  # pagination and other service stuff
  #
  class BaseClient
    METRICS_LABEL = 'acme/%<endpoint_name>s'

    private

    def request(name, access_token, params = {}, &block)
      with_retry { with_metrics(name) { block.call(client(access_token)) } }
    rescue AcmeSDK::ApiError => e
      log_error(e, name, params)
      raise
    end

    def client(access_token)
      AcmeSDK::ApiClint.new(access_token)
    end

    def with_retry(retries_count = 0)
      yield
    rescue AcmeSDK::ServerError, AcmeSDK::RequestTimeoutError => e
      raise if retries_count > 2

      logger.error(e, "Acme API call failed, retrying (#{retries_count})...")
      retries_count += 1
      retry
    end

    def with_metrics(name, &block)
      start_time = current_time
      label = format(METRICS_LABEL, endpoint_name: name)

      result = block.call
      send_metrics(label, 200, start_time)

      result
    rescue AcmeSDK::ApiError => e
      status = JSON.parse(e.body)['error']['code']
      send_metrics(label, status, start_time)
      raise
    rescue OAuth2::Error => e
      send_metrics(label, e.response.status, start_time)
      raise
    end
  end
end

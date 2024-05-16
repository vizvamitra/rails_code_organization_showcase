# frozen_string_literal: true

module Acme
  # A list of enpoints that we use. It'll tend to grow so I've extracted them
  # into a separate class
  #
  class ApiClient < BaseClient
    def identity(access_token:, **options)
      request(:identity, access_token, **options) { |api| api.identity(**options) }
    end

    def ad_accounts(access_token:, **options)
      request(:ad_accounts, access_token, **options) { |api| api.ad_accounts(**options) }
    end

    def ads(access_token:, **options)
      request(:ads, access_token, **options) { |api| api.ads(**options) }
    end
  end
end

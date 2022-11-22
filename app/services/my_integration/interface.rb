module MyIntegration
  class Interface < ::DomainInterface
    logging_prefix 'MyIntegration'
    filtered_params %i[access_token]

    # ...

    # @param account_id [Integer]
    # @param external_id [String]
    # @param access_token [String]
    #
    # @return [Success<>,Failure<Symbol>]
    # @raise [SomeApiClient::ApiError]
    # @raise [ActiveRecord::RecordNotFound]
    #
    def validate_identity(**args)
      with_logging { Identities::ValidateCreate.new.call(**args) }
    end
  end
end

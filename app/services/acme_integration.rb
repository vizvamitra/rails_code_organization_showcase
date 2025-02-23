module AcmeIntegration
  Error = Class.new(StandardError)
  AccessTokenInvalidError = Class.new(Error)
  PermissionMissingError = Class.new(Error)

  def self.table_name_prefix
    "acme_integration_"
  end
end

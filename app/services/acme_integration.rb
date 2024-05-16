module AcmeIntegration
  Error = Class.new(StandardError)
  AccessTokenInvalidError = Class.new(Error)
  PermissionMissingError = Class.new(Error)
  AdminRoleMissingError = Class.new(Error)
  AdAccountMissingError = Class.new(Error)
  # ...

  # For models
  def self.table_name_prefix
    'acme_'
  end
end

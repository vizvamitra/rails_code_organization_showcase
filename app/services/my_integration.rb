module MyIntegration
  Error = Class.new(StandardError)
  AccessTokenInvalidError = Class.new(Error)
  PermissionMissingError = Class.new(Error)
  IdentityNotFoundError = Class.new(Error)
  # ...

  # For models
  def self.table_name_prefix
    'my_integration_'
  end
end

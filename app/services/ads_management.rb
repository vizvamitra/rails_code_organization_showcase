module AdsManagement
  Error = Class.new(StandardError)
  # ...

  # For models
  def self.table_name_prefix
    'ads_management_'
  end
end

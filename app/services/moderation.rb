module Moderation
  Error = Class.new(StandardError)
  CommentFeedNotModeratableError = Class.new(Error)

  def self.table_name_prefix
    "moderation_"
  end
end

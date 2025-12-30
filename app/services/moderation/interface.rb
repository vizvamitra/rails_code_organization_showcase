module Moderation
  class Interface < Subsystems::Interface
    def sync_comment_feed(**params)
      with_logging { Moderation::CommentFeeds::Sync.new.call(**params) }
    end

    def toggle_comment_feed_connection_status(**params)
      with_logging { Moderation::CommentFeeds::ToggleConnectionStatus.new.call(**params) }
    end

    def list_comment_feeds(**params)
      Moderation::CommentFeeds::List.new.call(**params)
    end

    def toggle_comment_feed_moderation(**params)
      with_logging { Moderation::CommentFeeds::ToggleModeration.new.call(**params) }
    end
  end
end

module AcmeIntegration
  module Identities
    Attributes = Data.define(
      :id,
      :name,
      :avatar_url,
      :access_token,
      :permission_public_profile_read,
      :permission_pages_read,
      :permission_page_comments_read,
      :permission_page_comments_manage
    )
  end
end

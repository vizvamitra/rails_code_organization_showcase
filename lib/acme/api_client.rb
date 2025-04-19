module Acme
  class ApiClient
    def get_identity(access_token:)
      {
        "data" => {
          "id" => "123",
          "name" => "Temp",
          "avatar_url" => "https://example.com/avatar_url.png",
          "permissions" => [
            "public_profile_read",
            "pages_read",
            "page_comments_read",
            "page_comments_manage"
          ]
        }
      }
    end

    def get_pages(access_token:)
      {
        "data" => [
          {
            "id" => "456",
            "name" => "Whatever",
            "avatar_url" => "https://example.com/avatar.png",
            "roles" => ["manager"]
          },
          {
            "id" => "789",
            "name" => "Whatever 2",
            "avatar_url" => "https://example.com/avatar.png",
            "roles" => ["viewer"]
          }
        ]
      }
    end
  end
end

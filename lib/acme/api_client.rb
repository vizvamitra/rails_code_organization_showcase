module Acme
  class ApiClient
    def get_identity(access_token:)
      {
        "data" => {
          "id" => "123",
          "name" => "Temp",
          "avatar_url" => "https://example.com/avatar_url.png",
          "permissions" => []
        }
      }
    end

    def get_pages(access_token:)
      []
    end
  end
end

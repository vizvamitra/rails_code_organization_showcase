require "rack/test"

module ApiHelpers
  include Rack::Test::Methods

  ### Authentication

  def login(user, password)
    params = { user: { email_address: user.email_address, password: } }
    response = post("/api/authentication", params:)
    token = response.dig('data', 'access_token')

    header('Authorization', "Bearer #{token}")

    if block_given?
      yield
      logout
    end
  end

  def logout
    header('Authorization', nil)
  end

  ### Moderation

  def get_moderation_comment_feeds
    get("api/moderation/comment_feeds")['data']
  end

  ### Acme Integration

  def create_acme_identity(access_token)
    post("api/acme/identities", params: { identity: { access_token: } })['data']
  end

  def get_acme_pages
    get("api/acme/pages")['data']
  end

  ### Low-level stuff

  def app
    Rails.application
  end

  %i(get post put patch delete head).each do |http_method|
    define_method(http_method) do |path, headers: {}, params: {}|
      result = with_headers(headers) { super(path, params) }

      if result.headers['content-type'] =~ /json/
        JSON.parse(result.body)
      else
        result.body
      end
    end
  end

  private

  def with_headers(headers)
    headers.each { |k, v| header(k.to_s, v) }
    yield
  ensure
    headers.each { |k, _| header(k.to_s, nil) }
  end
end

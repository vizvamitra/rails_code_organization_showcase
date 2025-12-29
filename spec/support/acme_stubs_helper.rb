module AcmeStubsHelper
  def stub_acme_identity(access_token, identity)
    stub_request(:get, %r{^https://api.acme.com/me})
      .with { |r| r.headers["Authorization"] == "Bearer #{access_token}" }
      .to_return(
        status: 200,
        body: { data: identity, meta: {} }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_acme_pages(access_token, pages)
    stub_request(:get, %r{^https://api.acme.com/pages})
      .with { |r| r.headers["Authorization"] == "Bearer #{access_token}" }
      .to_return(
        status: 200,
        body: { data: pages, meta: {} }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end

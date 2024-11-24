module AuthenticationHelpers
  def sign_in(user)
    post(
      "/session",
      params: { email_address: user.email_address, password: "12345678" }
    )
  end

  def sign_out
    delete "/session"
  end
end

class ApiController < ApplicationController
  include Api::ErrorHandling
  include Api::TokenAuthentication

  # I'm turning off CSRF protection for simplicity. Production-grade security
  # is not the focus of this repo. Don't consider it a recommendation please.
  #
  skip_before_action :verify_authenticity_token
end

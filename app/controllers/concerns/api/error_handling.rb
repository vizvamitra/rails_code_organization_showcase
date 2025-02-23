module Api
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      ActionDispatch::ExceptionWrapper.rescue_responses.keys.each do |class_name|
        rescue_from(class_name.constantize) { |e| render_public_error(e) }
      end

      rescue_from(HttpErrors::Error) { |e| render_http_error(e) }
    end

    private

    def render_http_error(error)
      if error.is_a?(HttpErrors::TooManyRequestsError)
        response.headers['Retry-After'] = error.retry_after
      end

      serialized = HttpErrorSerializer.new([error]).as_json(root_key: :errors)
      render(status: error.status, json: serialized)
    end

    def render_public_error(error)
      serialized = PublicErrorSerializer.new([error]).as_json(root_key: :errors)
      render(status: serialized["errors"].first["status"], json: serialized)
    end
  end
end

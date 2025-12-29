module HttpErrors
  def self.register(error_class)
    ActionDispatch::ExceptionWrapper.rescue_responses[error_class.name] = error_class.error_type
  end

  class Error < StandardError
    attr_reader :message_id

    def self.error_type
      self.name.demodulize.sub(/Error$/, "").underscore.to_sym
    end

    def initialize(message_id = nil, *)
      @message_id = message_id || self.class.error_type
    end

    def status
      ActionDispatch::ExceptionWrapper.status_code_for_exception(self.class.name)
    end

    def message
      I18n.t("#{i18n_base_path}.#{message_id}", default: message_id.to_s.humanize)
    end

    def inspect
      "#<#{self.class}: #{message}>"
    end

    private

    def i18n_base_path
      "http_errors.#{self.class.error_type}"
    end
  end

  # 400
  BadRequestError = Class.new(Error)
  register(BadRequestError)

  # 401
  UnauthorizedError = Class.new(Error)
  register(UnauthorizedError)

  # 403
  ForbiddenError = Class.new(Error)
  register(ForbiddenError)

  # 404
  NotFoundError = Class.new(Error)
  register(NotFoundError)

  # 406
  NotAcceptableError = Class.new(Error)
  register(NotAcceptableError)

  # 409
  ConflictError = Class.new(Error)
  register(ConflictError)

  # 422
  UnprocessableContentError = Class.new(Error)
  register(UnprocessableContentError)

  # 429
  class TooManyRequestsError < Error
    def initialize(message_id = nil, retry_after)
      @retry_after = retry_after
      super(message_id)
    end

    attr_reader :retry_after
  end
  register(TooManyRequestsError)

  # 500
  InternalServerError = Class.new(Error)
  register(InternalServerError)
end

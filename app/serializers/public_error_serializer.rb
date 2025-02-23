class PublicErrorSerializer < ApplicationSerializer
  attributes :status, :title, :detail

  def status(error)
    ActionDispatch::ExceptionWrapper.status_code_for_exception(error.class.name)
  end

  def title(error)
    ActionDispatch::ExceptionWrapper.rescue_responses[error.class.name]
  end

  def detail(error)
    t = title(error)
    I18n.t("http_errors.#{t}.#{t}", default: t.to_s.humanize)
  end
end

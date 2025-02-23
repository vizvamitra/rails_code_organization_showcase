class HttpErrorSerializer < ApplicationSerializer
  attributes :status, :title, :detail

  def title(error)
    error.message_id
  end

  def detail(error)
    error.message
  end
end

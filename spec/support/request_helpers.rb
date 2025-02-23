module RequestHelpers
  def json
    JSON.parse(response.body) rescue nil
  end
end

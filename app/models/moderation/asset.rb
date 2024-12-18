module Moderation
  class Asset < ApplicationRecord
    belongs_to :client

    enum :source, { acme: 0, meta: 1 }
  end
end

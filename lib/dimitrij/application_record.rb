class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def primary_key
      'id'
    end
  end
end

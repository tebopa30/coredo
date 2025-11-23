class History < ApplicationRecord
  belongs_to :session
  belongs_to :dish
end

class Session < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :dish, optional: true
end

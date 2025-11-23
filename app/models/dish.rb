class Dish < ApplicationRecord
  has_many :options
  has_many :histories
  validates :name, presence: true
end

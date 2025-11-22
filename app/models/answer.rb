class Answer < ApplicationRecord
  belongs_to :session
  belongs_to :question
  belongs_to :option
end

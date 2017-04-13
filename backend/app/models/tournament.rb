class Tournament < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end

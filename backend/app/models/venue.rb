class Venue < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :matches
end

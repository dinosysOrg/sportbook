class Venue < ApplicationRecord
  has_many :matches

  auto_strip_attributes :calendar_id

  validates :name, presence: true, uniqueness: true
end

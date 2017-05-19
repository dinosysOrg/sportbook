class Page < ApplicationRecord
  belongs_to :tournament

  validates :tournament, presence: true
  validates :name, presence: true
  validates :locale, presence: true
end

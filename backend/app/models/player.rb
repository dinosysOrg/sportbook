class Player < ApplicationRecord
  belongs_to :user
  belongs_to :tournament
  belongs_to :team
end

class TimeBlock < ApplicationRecord
  serialize :preferred_time
  belongs_to :team
end

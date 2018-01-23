class Game < ApplicationRecord
  belongs_to :team_a, class_name: 'Team'
  belongs_to :team_b, class_name: 'Team'
  belongs_to :channel

  scope :this_month, -> { where(created_at: Date.current.beginning_of_month.beginning_of_day..Time.current) }
end

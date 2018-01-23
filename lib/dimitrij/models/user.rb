class User < ApplicationRecord
  belongs_to :server
  has_many :teams_users
  has_many :teams, through: :teams_users

  scope :on_channel, ->(channel_id) { joins(:teams).where(teams: { channel_id: channel_id }) }

  def self.mvp
    all.max { |u| u.teams.sum { |t| t.games_won.length } }
  end
end

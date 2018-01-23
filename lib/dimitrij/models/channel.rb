class Channel < ApplicationRecord
  enum language: %i[de en]
  belongs_to :server
  has_many :teams
  has_many :games

  def self.call(id)
    find_or_create_by(id: id)
  end

  def reminded_today?
    reminded_at&.strftime('%D') == Time.now.strftime('%D')
  end

  def set_reminded_at
    update(reminded_at: Time.now)
  end

  def combined_name
    (server && "#{server.name}/" || '') + name
  end
end


class Discordrb::Channel
  delegate :language, to: :db_channel

  private

  def db_channel
    ::Channel.call(id)
  end
end

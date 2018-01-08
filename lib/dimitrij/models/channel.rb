class Channel < ApplicationRecord
  enum language: %i[en de]

  def self.call(channel_id)
    find_or_create_by(channel_id: channel_id)
  end

  def reminded_today?
    reminded_at&.strftime('%D') == Time.now.strftime('%D')
  end

  def set_reminded_at
    update reminded_at: Time.now
  end
end


class Discordrb::Channel
  delegate :language, to: :db_channel

  private

  def db_channel
    ::Channel.call(id)
  end
end

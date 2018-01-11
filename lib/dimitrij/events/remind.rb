module Dimitrij::Events::Remind
  extend Discordrb::EventContainer
  heartbeat do
    Dimitrij::BOT.servers.keys.each do |server_id|
      Dimitrij::BOT.server(server_id).channels.each do |channel|
        next unless channel.text? && remind?(channel)
        I18n.with_locale(Channel.call(channel.id).language) do
          channel.send I18n.t('reminder_bot.message')
        end
        Channel.call(channel.id).set_reminded_at
      end
    end
  end

  def self.remind?(channel)
    return false unless Time.now.hour == 15
    !Channel.call(channel.id).reminded_today?
  end
end

module Dimitrij::Events::Heartbeat
  extend Discordrb::EventContainer

  heartbeat do |event|
    event.bot.servers.values.each do |server|
      bot_profile = event.bot.profile.on(server)

      server.text_channels.each do |channel|
        next unless permissions?(bot_profile, channel) && remind?(channel)

        I18n.with_locale(Channel.call(channel.id).language) do
          channel.send I18n.t('reminder_bot.message')
        end
        Channel.call(channel.id).set_reminded_at
      end
    end
  end

  class << self
    def remind?(channel)
      return false unless Time.now.hour == 15
      !Channel.call(channel.id).reminded_today?
    end

    def permissions?(bot_profile, channel)
      %i[read_messages send_messages].each do |permission|
        return false unless bot_profile.permission?(permission, channel)
      end
      true
    end
  end
end

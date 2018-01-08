class ReminderBot
  HOUR_TO_REMIND_AT = 15

  class << self
    def call
      loop do
        Dimitrij::BOT.servers.keys.each do |server_id|
          Dimitrij::BOT.server(server_id).channels.each do |channel|
            next unless channel.text? && remind?(channel)
            I18n.with_locale(Channel.call(channel.id).language) do
              channel.send I18n.t('reminder_bot.message')
            end
            Channel.call(channel.id).set_reminded_at
          end
        end
        sleep 10
      end
    end

    private

    def remind?(channel)
      return false unless Time.now.hour == HOUR_TO_REMIND_AT
      !Channel.call(channel.id).reminded_today?
    end
  end
end

module Dimitrij::Commands::Lang
  extend Discordrb::Commands::CommandContainer

  command(:lang, description: "[en|de] Change the language.") do |event, language|
    channel = Channel.call(event.channel.id)

    if Channel.languages.keys.include? language
      channel.update language: language
      I18n.with_locale(language) { event.respond I18n.t('language.changed') }
    else
      I18n.with_locale(channel.language) do
        message = event.respond I18n.t('language.choose')
        message.react '🇩🇪'
        message.react '🇬🇧'

        Dimitrij::BOT.add_await(:"lang_de_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: '🇩🇪') do |reaction_event|
          next unless reaction_event.message.id == message.id
          message.delete
          channel.update language: :de
          I18n.with_locale(:de) { event.respond I18n.t('language.changed') }
        end

        Dimitrij::BOT.add_await(:"lang_en_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: '🇬🇧') do |reaction_event|
          next unless reaction_event.message.id == message.id
          message.delete
          channel.update language: :en
          I18n.with_locale(:en) { event.respond I18n.t('language.changed') }
        end
      end
    end
    nil
  end
end

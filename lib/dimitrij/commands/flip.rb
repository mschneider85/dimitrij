module Dimitrij::Commands::Flip
  extend Discordrb::Commands::CommandContainer
  command(:flip, description: 'Fip a coin.') do |event|
    I18n.with_locale(event.channel.language) do
      I18n.t("flip.#{%w[heads tails].sample}")
    end
  end
end

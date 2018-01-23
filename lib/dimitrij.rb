require_relative 'environment'

module Dimitrij
  CONFIG = YAML.load_file('config/discord.yml')

  BOT = Discordrb::Commands::CommandBot.new(
    token: CONFIG['token'],
    client_id: CONFIG['client_id'],
    prefix: '!'
  )
  Discordrb::LOGGER.info "This bot's invite URL is #{BOT.invite_url}."

  require_relative 'dimitrij/commands'
  require_relative 'dimitrij/events'

  Dimitrij::Commands.include!
  Dimitrij::Events.include!

  BOT.run
end

module Dimitrij::Events::Ready
  extend Discordrb::EventContainer

  ready do |event|
    # Set Playing ...
    event.bot.game = 'Table tennis'

    # Persist active servers
    Dimitrij::BOT.servers.values.each do |server|
      db_server = Server.where(id: server.id).first_or_create(name: server.name)

      # Persist active channels
      server.text_channels.each do |channel|
        Channel.where(id: channel.id).first_or_create(name: channel.name, server: db_server)
      end
    end
  end
end

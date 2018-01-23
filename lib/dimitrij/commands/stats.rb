module Dimitrij::Commands::Stats
  A = '🇦'.freeze
  B = '🇧'.freeze

  extend Discordrb::Commands::CommandContainer
  command(:stats, description: 'Show team stats') do |event|
    Team.leaderboard(channel_id: event.channel.id)
  end
end

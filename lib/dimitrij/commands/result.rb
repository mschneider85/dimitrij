module Dimitrij::Commands::Result
  A = '🇦'.freeze
  B = '🇧'.freeze
  CROSS_MARK = '❌'.freeze

  extend Discordrb::Commands::CommandContainer
  command(:result, description: 'Add game results.') do |event|
    game = Game.order(created_at: :desc)
               .where(winner: nil, channel_id: event.channel.id)
               .where('date(created_at) = ?', Date.today)
               .last
    game.present? ? RegisterScore.call(game, event) : event.respond('Kein Spiel gefunden.')
    nil
  end

  class RegisterScore
    def self.call(game, event)
      message = event.respond <<~HEREDOC
        Spiel gefunden.
        **Team A:** #{game.team_a&.players}
        **Team B:** #{game.team_b&.players}
        Gewinner auswählen oder Spiel löschen...
      HEREDOC
      message.create_reaction A
      message.create_reaction B
      message.create_reaction CROSS_MARK

      Dimitrij::BOT.add_await(:"team_a_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: A) do |team_reaction_event|
        next unless team_reaction_event.message.id == message.id && team_reaction_event.user == event.user
        unless game.winner.present?
          game.update(winner: 'a')
          message.delete
          event.respond "GG. Team A (#{game.team_a.players}) hat gewonnen."
        end
      end

      Dimitrij::BOT.add_await(:"team_b_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: B) do |team_reaction_event|
        next unless team_reaction_event.message.id == message.id && team_reaction_event.user == event.user
        unless game.winner.present?
          game.update(winner: 'b')
          message.delete
          event.respond "GG. Team B (#{game.team_b.players}) hat gewonnen."
        end
      end

      Dimitrij::BOT.add_await(:"delete_game_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: CROSS_MARK) do |team_reaction_event|
        next unless team_reaction_event.message.id == message.id && team_reaction_event.user == event.user
        unless game.winner.present?
          game.destroy
          message.delete
          event.respond 'Spiel gelöscht.'
        end
      end
    end
  end
end

module Dimitrij::Commands::Tt
  CHECK_MARK = "\u2705".freeze
  PING_PONG = '🏓'.freeze

  def self.starting_message(user)
    <<~HEREDOC
      ---------------------------------------------------
      #{PING_PONG} #{I18n.t('tt.lets_play')} #{PING_PONG}
      ---------------------------------------------------
      #{I18n.t('tt.started_a_match', player: user.name)}
      #{I18n.t('tt.waiting')}
    HEREDOC
  end

  def self.team_message(users)
    user_names = users.map(&:name).shuffle
    left, right = user_names.each_slice((user_names.size / 2.0).round).to_a.map { |team| team.join(', ') }
    left, right = [left, right].shuffle
    <<~HEREDOC
      ---------------------------------------------------
      #{PING_PONG} #{I18n.t('tt.complete')} #{PING_PONG}
      ---------------------------------------------------
      Team A: #{left}
      Team B: #{right}
    HEREDOC
  end

  extend Discordrb::Commands::CommandContainer
  command(:tt, description: 'Start a new table tennis game.') do |event|
    I18n.with_locale(event.channel.language) do
      users = [event.user]
      notifications = []
      message = event.respond starting_message(event.user)
      message.create_reaction CHECK_MARK

      Dimitrij::BOT.add_await(:"join_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: CHECK_MARK) do |reaction_event|
        next unless reaction_event.message.id == message.id

        if reaction_event.user == event.user
          notifications.each(&:delete)
          message.delete
          I18n.with_locale(event.channel.language) do
            event.respond team_message(users)
          end
          event.respond 'GL & HF'
          true
        else
          if users.index(reaction_event.user)
            users.delete(reaction_event.user)
            I18n.with_locale(event.channel.language) { notifications << event.respond(I18n.t('tt.left', player: reaction_event.user.name)) }
          else
            users << reaction_event.user
            I18n.with_locale(event.channel.language) { notifications << event.respond(I18n.t('tt.joined', player: reaction_event.user.name)) }
          end
          false
        end
      end
    end
    nil
  end
end

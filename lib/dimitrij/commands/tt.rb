module Dimitrij::Commands::Tt
  CHECK_MARK = "\u2705".freeze
  PING_PONG = '🏓'.freeze

  class << self
    def starting_message(user)
      <<~HEREDOC
        ---------------------------------------------------
        #{PING_PONG} #{I18n.t('tt.lets_play')} #{PING_PONG}
        ---------------------------------------------------
        #{I18n.t('tt.started_a_match', player: user.name)}
        #{I18n.t('tt.waiting')}
      HEREDOC
    end

    def team_message(users)
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
  end

  extend Discordrb::Commands::CommandContainer
  bucket :new_games, limit: 3, time_span: 60, delay: 10
  command(
    :tt,
    description: 'Start a new table tennis game.',
    bucket: :new_games,
    rate_limit_message: 'Calm down for %time% more seconds!'
  ) do |event|
    users = [event.user]
    notifications = []
    message = event.respond(I18n.with_locale(event.channel.language) { starting_message(event.user) })
    message.create_reaction CHECK_MARK

    Dimitrij::BOT.add_await(:"join_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: CHECK_MARK) do |reaction_event|
      next if reaction_event.user.id == Dimitrij::CONFIG['client_id']
      next unless reaction_event.message.id == message.id

      if reaction_event.user == event.user
        notifications.each(&:delete)
        message.delete
        I18n.with_locale(event.channel.language) { event.respond team_message(users) }
        message = event.respond 'GL & HF'
        true
      else
        if users.index(reaction_event.user)
          users.delete(reaction_event.user)
          notifications << event.respond(I18n.t('tt.left', player: reaction_event.user.name, locale: event.channel.language))
        else
          users << reaction_event.user
          notifications << event.respond(I18n.t('tt.joined', player: reaction_event.user.name, locale: event.channel.language))
        end
        false
      end
    end
    nil
  end
end

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

    def create_teams(users, channel_id)
      users = users.map do |user|
        User.find_by(id: user.id) || User.create(
          id: user.id,
          name: user.name,
          discriminator: user.discriminator
        )
      end

      users = users.shuffle
      left, right = users.each_slice((users.size / 2.0).round).to_a
      left, right = [left, right].shuffle

      team = Team.find_by(channel_id: channel_id, player_ids: (left || []).map(&:id).sort)
      left_team = team || left && Team.create(channel_id: channel_id, users: left.sort_by(&:id))

      team = Team.find_by(channel_id: channel_id, player_ids: (right || []).map(&:id).sort)
      right_team = team || right && Team.create(channel_id: channel_id, users: right.sort_by(&:id))

      {
        left: left_team,
        right: right_team
      }
    end

    def team_message(teams)
      <<~HEREDOC
        ---------------------------------------------------
        #{PING_PONG} #{I18n.t('tt.complete')} #{PING_PONG}
        ---------------------------------------------------
        Team A: #{teams[:left]&.players}
        Team B: #{teams[:right]&.players}
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
      next unless reaction_event.message.id == message.id

      if reaction_event.user == event.user
        notifications.each(&:delete)
        message.delete

        teams = create_teams(users, reaction_event.channel.id)
        Game.create(channel_id: reaction_event.channel.id, team_a: teams[:left], team_b: teams[:right])

        I18n.with_locale(event.channel.language) { event.respond team_message(teams) }
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

#!/usr/bin/env ruby

require_relative 'environment'

CLOCK3 = '🕒'.freeze

Bot.message do |event|
  if @reminded_at != Time.now.strftime('%D') && Time.now.hour == 15
    event.respond "#{CLOCK3} IT'S TABLE TENNIS O'CLOCK! #{CLOCK3}"
    @reminded_at = Time.now.strftime('%D')
  end
end

CHECK_MARK = "\u2705".freeze
PING_PONG = '🏓'.freeze

def starting_message(user)
  <<~HEREDOC
    ---------------------------------------------------
    #{PING_PONG} LET'S PLAY TABLE TENNIS! #{PING_PONG}
    ---------------------------------------------------
    #{user.name} started a new match.
    Waiting for players to join...
  HEREDOC
end

def team_message(users)
  user_names = users.map(&:name).shuffle
  left, right = user_names.each_slice((user_names.size / 2.0).round).to_a.map { |team| team.join(', ') }
  left, right = [left, right].shuffle
  <<~HEREDOC
    ---------------------------------------------------
    #{PING_PONG} TEAMS ARE COMPLETE! #{PING_PONG}
    ---------------------------------------------------
    Team A: #{left}
    Team B: #{right}
  HEREDOC
end

Bot.message(content: '!tt') do |event|
  @reminded_at = Time.now.strftime('%D')
  users = [event.user]
  notifications = []
  message = event.respond starting_message(event.user)
  message.create_reaction CHECK_MARK

  Bot.add_await(:"join_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: CHECK_MARK) do |reaction_event|
    next unless reaction_event.message.id == message.id

    if reaction_event.user == event.user
      notifications.each(&:delete)
      message.delete
      event.respond team_message(users)
      event.respond 'GL & HF'
      true
    else
      if users.index(reaction_event.user)
        users.delete(reaction_event.user)
        notifications << event.respond("#{reaction_event.user.name} left the team.")
      else
        users << reaction_event.user
        notifications << event.respond("#{reaction_event.user.name} joined the team.")
      end
      false
    end
  end
end

Bot.run

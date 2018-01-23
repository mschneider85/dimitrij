class Team < ApplicationRecord
  belongs_to :channel
  has_many :teams_users
  has_many :users, through: :teams_users

  delegate :language, to: :channel, prefix: true, allow_nil: true

  serialize :player_ids

  before_save do
    self.player_ids = users.map(&:id)
  end

  class << self
    def leaderboard(channel_id:)
      channel = Channel.call(channel_id)

      teams = channel_id ? where(channel_id: channel_id) : all
      best10 = teams.sort(&:games_won).reverse[0..9]

      max_team_length = teams.map { |c| c.players.length }.max || 0
      max_games_won_length = best10.first&.games_won&.length&.digits&.length || 0
      max_games_lost_length = best10.max(&:games_lost)&.games_lost&.length&.digits&.length || 0

      @str = '```Markdown'

      @str << "\n**#{channel.combined_name}**"
      @str << "\n\n---"

      @str << "\n\n##Channel Stats\n"

      @str << "\nTotal games played: #{channel.games.length}"
      @str << "\nGames played this month: #{channel.games.this_month.length}"
      @str << "\nMVP: #{User.on_channel(channel_id).mvp.name}"

      @str << "\n\n##Leaderboard\n"

      @str << [
        "\n|" + ' # ',
        'Team'.center(max_team_length + 2),
        'W'.center(max_games_won_length + 2),
        'L'.center(max_games_lost_length + 2),
        'W%'.center(9) + '|'
      ].join('|')

      @str << [
        "\n|" + '---',
        dashes(max_team_length + 2),
        dashes(max_games_won_length + 2),
        dashes(max_games_lost_length + 2),
        dashes(9) + '|'
      ].join('|')

      best10.each.with_index(1) do |team, index|
        @str << [
          "\n|#{index.to_s.rjust(2)} ",
          ' ' + team.players.ljust(max_team_length) + ' ',
          ' ' + team.games_won.length.to_s.rjust(max_games_won_length) + ' ',
          ' ' + team.games_lost.length.to_s.rjust(max_games_lost_length) + ' ',
          ' ' + team.win_ratio + ' ' + '|'
        ].join('|')
      end
      @str << "\n```"
      @str
    end

    private

    def dashes(i)
      (1..i).map { |_n| '-' }.join
    end
  end

  def players
    users.map(&:name).to_sentence(locale: locale)
  end

  def games_won
    @games_won ||= Game.where(team_a_id: id, winner: 'a').union(Game.where(team_b_id: id, winner: 'b'))
  end

  def games_lost
    @games_lost ||= Game.where(team_a_id: id, winner: 'b').union(Game.where(team_b_id: id, winner: 'a'))
  end

  def win_ratio
    return '  0.00%' if (games_won.length + games_lost.length).zero?
    percentage = (100.0 * games_won.length / (games_won.length + games_lost.length))
    format('%6.2f%', percentage)
  end

  private

  def locale
    channel_language || :en
  end
end

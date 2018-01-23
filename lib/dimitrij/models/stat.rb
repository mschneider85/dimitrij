class Stat
  include ActiveModel::Model

  attr_accessor :channel

  def teams
    channel_teams.map do |team|
      {
        team: team.players,
        wins: channel_games.where(team_a: team, winner: 'a').or(channel_games.where(team_b: team, winner: 'b')).length
      }
    end.sort_by { |t| t[:wins] }
  end

  def players; end

  private

  def channel_teams
    channel.teams
  end

  def channel_games
    channel.games
  end
end

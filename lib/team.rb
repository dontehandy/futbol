class Team
  attr_reader :team_id, :team_name, :games_played

  def initialize(team_data)
    @team_id = team_data[:team_id].to_i
    @team_name = team_data[:teamname]

    @games_played = []      
  end

  def associate_games_with_team(all_games)

    @games_played = all_games.find_all do |game|
      game.game_stats[:home][:team_id] == @team_id || game.game_stats[:away][:team_id] == @team_id
    end

  end

end
   

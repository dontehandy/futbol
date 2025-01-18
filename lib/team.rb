class Team
  attr_reader :team_id, :team_name

  def initialize(team_data)
    @team_id = team_data[:team_id]
    @team_name = team_data[:teamname]

    @games_played = []      #Array of all games (objects) this team has played in (home and away)
  end

  def associate_games_with_team(all_games)
    @games_played = all_games.find_all do |game|
      game.game_stats[:home][:team_id] == @team_id || game.game_stats[:away][:team_id] == @team_id
    end

    #Optional implementation: separate into two instance vars, @home_games_played and @away_games_played:
    # all_games.each do |game|
    #   if game.game_stats[:home][:team_id] == @team_id
    #     @home_games_played << game
    #   elsif game.game_stats[:away][:team_id] == @team_id
    #     @away_games_played << game
    #   end
  end

end
   

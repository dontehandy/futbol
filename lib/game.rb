class Game
  attr_reader :game_id, :season, :type, :date_time, :game_stats

  def initialize(game_data, game_teams_home_data, game_teams_away_data)
    #IMPORTANT: game_data, game_teams_data are data for ONLY THIS game - needs to be selected before passing in!
    #Each game only needs some of the raw data
    #Access it similar to a hash (it is of CSV format, though .to_h and .to_a work as well)
    @game_id = game_data[:game_id]
    @season = game_data[:season]
    @type = game_data[:type]
    @date_time = game_data[:date_time]

    @game_stats = {
      :home => {team: nil,                     
        team_id: game_data[:home_team_id].to_i,
        goals: game_data[:home_goals].to_i,
        result: game_teams_home_data[:result],
        head_coach: game_teams_home_data[:head_coach],
        shots: game_teams_home_data[:shots].to_i,
        tackles: game_teams_home_data[:tackles].to_i},
      :away => {team: nil,
        team_id: game_data[:away_team_id].to_i,
        goals: game_data[:away_goals].to_i,
        result: game_teams_away_data[:result],
        head_coach: game_teams_away_data[:head_coach],
        shots: game_teams_away_data[:shots].to_i,
        tackles: game_teams_away_data[:tackles].to_i}
    }
    
  end

  def associate_teams_with_game(all_teams)
    
    return nil if !all_teams || all_teams.length == 0

    @game_stats[:away][:team] = all_teams.find do |team|
      team.team_id.to_i == @game_stats[:away][:team_id]
    end
    @game_stats[:home][:team] = all_teams.find do |team|
      team.team_id.to_i == @game_stats[:home][:team_id]
    end
  end

end
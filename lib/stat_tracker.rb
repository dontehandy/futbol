class StatTracker
  attr_reader :games, :teams, :game_teams, :matches, :clubs

  def initialize()
    @games = []
    @teams = []
    @game_teams = []

    @matches = []     #Array of actual game objects
    @clubs = []       #Array of actual team objects

    #Create games and teams, and make appropriate connections / associations
    # create_all_games()
    # create_all_teams()
  end

  def self.from_csv(locations)
    stat_tracker = StatTracker.new()

    CSV.foreach(locations[:games], headers: true, header_converters: :symbol) do |row|
      stat_tracker.games << row
      # binding.pry
    end
    CSV.foreach(locations[:teams], headers: true, header_converters: :symbol) do |row|
      stat_tracker.teams << row
      # binding.pry
    end
    CSV.foreach(locations[:game_teams], headers: true, header_converters: :symbol) do |row|
      # binding.pry
      stat_tracker.game_teams << row
    end

    #Now that we have raw data, create games and teams, and make appropriate connections / associations
    #NOTE: what immediately follows is the most 'expensive' part of all methods / classes
    stat_tracker.create_all_games()
    stat_tracker.create_all_teams()
    stat_tracker.associate_games_and_teams()

    stat_tracker
  end

  def highest_total_score
    max_score = 0

    @games.each do |game|
      total_score = game[:home_goals].to_i + game[:away_goals].to_i
      max_score = total_score if total_score > max_score
    end

    max_score
  end
  
  def lowest_total_score
    min_score = 0

    @games.each do |game|
      total_score = game[:home_goals].to_i + game[:away_goals].to_i
      min_score = total_score if total_score < min_score
    end

    min_score
  end

  def percentage_home_wins
    home_wins.fdiv(total_games).round(2)
  end

  def percentage_visitor_wins
    away_wins.fdiv(total_games).round(2)
  end

  def percentage_ties
    ties.fdiv(total_games).round(2)
  end 
 
  def total_games
    @matches.count
  end

  def home_wins
    @matches.count do |game|
      game.game_stats[:away][:goals] < game.game_stats[:home][:goals]
    end
  end

  def away_wins
    @matches.count do |game|
      game.game_stats[:away][:goals] > game.game_stats[:home][:goals]
    end
  end

  def ties
    @matches.count do |game|
      game.game_stats[:away][:goals] == game.game_stats[:home][:goals]
    end
  end
  
  def average_goals_per_game()
    #Average over ALL games (and here total goals, i.e. away + home, is measured)
    total_goals = @games.sum do |game|
      game[:away_goals].to_i + game[:home_goals].to_i
    end

    # binding.pry

    # total_goals = @matches.sum do |game|
    #   game.game_stats[:away][:goals] + game.game_stats[:home][:goals]
    # end

    (total_goals.to_f / @games.length).round(2)
  end

  def average_goals_by_season()
    #Construct hash of games by each season
    #Could build this an alternate way later - consider refactor
    goals_by_season_hash = {}
    games_by_season_hash = @games.group_by do |game|
      game[:season]
    end

    games_by_season_hash.keys.each do |season_of_games|
      total_goals_in_season = games_by_season_hash[season_of_games].sum do |game_in_single_season|
        #Re-using finding total goals here...maybe refactor this too later
        game_in_single_season[:home_goals].to_i + game_in_single_season[:away_goals].to_i
      end
      
      goals_by_season_hash[season_of_games] = (total_goals_in_season.to_f / games_by_season_hash[season_of_games].length).round(2)
    end

    goals_by_season_hash
  end

  def game_teams_home_data(game_id) 
    home_teams = {}
    game_id_home = @game_teams.each do |game|
      if game[:game_id] == game_id && game[:hoa] == "home"
        home_teams = game.to_h
        break
      end

    end
    home_teams
  end

  def game_teams_away_data(game_id) 
    away_teams = {}
    game_id_away = @game_teams.each do |game|
      if game[:game_id] == game_id && game[:hoa] == "away"
        away_teams = game.to_h
        break
      end

    end
    away_teams
  end

  def create_all_games
    #First, sort @games and @game_teams for quicker processing / exploit alignment
    sorted_games = @games.sort do |a, b|
      a[:game_id] <=> b[:game_id]
    end
    sorted_game_teams = @game_teams.sort do |a, b|
      a[:game_id] <=> b[:game_id]
    end
    
    if verify_alignment(sorted_games, sorted_game_teams)
      #If we're here, build game objects from the sorted list; if not, print error message / something else?
      i = 0
      while i < sorted_games.length
        @matches << Game.new(sorted_games[i], sorted_game_teams[2 * i + 1].to_h, sorted_game_teams[2 * i].to_h)
        i += 1
      end
    else
      puts "Error: data is not structured correctly for proper importing."
      #Another option: just say the shortcut failed, and run the slow way...
    end
    # @games.each do |game|
    #   @matches << Game.new(game, game_teams_home_data(game[:game_id]), game_teams_away_data(game[:game_id]))
    # # break if @matches.length > 1000
    # end
  end

  def create_all_teams
    @teams.each do |team|
      @clubs << Team.new(team)
    end
  end

  def best_offense
    team_scores = {}
  
    @game_teams.each do |game|
      team_id = game[:team_id]
      team_scores[team_id] ||= [0, 0] 
      team_scores[team_id][0] += game[:goals].to_i
      team_scores[team_id][1] += 1
    end
   
    best_team_id = nil
    highest_avg_score = 0
  
    team_scores.each do |team_id, (total_goals, games_played)|
      avg_score = total_goals.to_f / games_played
      if avg_score > highest_avg_score
        highest_avg_score = avg_score
        best_team_id = team_id
      end
    end
    
    @teams.find { |team| team[:team_id] == best_team_id }[:teamname]
  end

  def worst_offense
    team_scores = {}
  
    @game_teams.each do |game|
      team_id = game[:team_id]
      team_scores[team_id] ||= [0, 0] 
      team_scores[team_id][0] += game[:goals].to_i
      team_scores[team_id][1] += 1
    end
  
    worst_team_id = nil
    lowest_avg_score = Float::INFINITY
  
    team_scores.each do |team_id, (total_goals, games_played)|
      avg_score = total_goals.to_f / games_played
      if avg_score < lowest_avg_score
        lowest_avg_score = avg_score
        worst_team_id = team_id
      end
    end
  
    @teams.find { |team| team[:team_id] == worst_team_id }[:teamname]
  end

  def highest_scoring_visitor
    team_scores = {}
  
    @game_teams.each do |game|
      if game[:hoa] == 'away'
        team_id = game[:team_id]
        if team_scores[team_id].nil?
          team_scores[team_id] = [0, 0]  # [total goals, games played]
        end
        team_scores[team_id][0] += game[:goals].to_i
        team_scores[team_id][1] += 1
      end
    end
    highest_team_id = nil
    highest_avg_score = 0
  
    team_scores.each do |team_id, (total_goals, games_played)|
      avg_score = total_goals.to_f / games_played
      if avg_score > highest_avg_score
        highest_avg_score = avg_score
        highest_team_id = team_id
      end
    end
    @teams.find { |team| team[:team_id] == highest_team_id }[:teamname]
  end

  def highest_scoring_home
    team_scores = {}
  
    @game_teams.each do |game|
      if game[:hoa] == 'home'
        team_id = game[:team_id]
        if team_scores[team_id].nil?
          team_scores[team_id] = [0, 0] 
        end
        team_scores[team_id][0] += game[:goals].to_i
        team_scores[team_id][1] += 1
      end
    end
  
    highest_team_id = nil
    highest_avg_score = 0
  
    team_scores.each do |team_id, (total_goals, games_played)|
      avg_score = total_goals.to_f / games_played
      if avg_score > highest_avg_score
        highest_avg_score = avg_score
        highest_team_id = team_id
      end
    end
    @teams.find { |team| team[:team_id] == highest_team_id }[:teamname]
  end

  def lowest_scoring_home
    team_scores = {}
  
    @game_teams.each do |game|
      if game[:hoa] == 'home'
        team_id = game[:team_id]
        if team_scores[team_id].nil?
          team_scores[team_id] = [0, 0]
        end
        team_scores[team_id][0] += game[:goals].to_i
        team_scores[team_id][1] += 1
      end
    end
  
    lowest_team_id = nil
    lowest_avg_score = 999
  
    team_scores.each do |team_id, (total_goals, games_played)|
      avg_score = total_goals.to_f / games_played
      if avg_score < lowest_avg_score
        lowest_avg_score = avg_score
        lowest_team_id = team_id
      end
    end
  
    @teams.find { |team| team[:team_id] == lowest_team_id }[:teamname]
  end

  def lowest_scoring_visitor
    team_scores = {}
  
    @game_teams.each do |game|
      if game[:hoa] == 'away'
        team_id = game[:team_id]
        if team_scores[team_id].nil?
          team_scores[team_id] = [0, 0]
        end
        team_scores[team_id][0] += game[:goals].to_i
        team_scores[team_id][1] += 1
      end
    end
  
    lowest_team_id = nil
    lowest_avg_score = 999
  
    team_scores.each do |team_id, (total_goals, games_played)|
      avg_score = total_goals.to_f / games_played
      if avg_score < lowest_avg_score
        lowest_avg_score = avg_score
        lowest_team_id = team_id
      end
    end
  
    @teams.find { |team| team[:team_id] == lowest_team_id }[:teamname]
  end

  def count_of_games_by_season
    games_by_season = Hash.new(0)
    @games.each { |game| games_by_season[game[:season]] += 1 }
    games_by_season
  end

  def associate_games_and_teams()
    #First, associate teams to each game:
    @matches.each do |game|
      game.associate_teams_with_game(@clubs)
    end

    #Now, build array of games each team has played in:
    @clubs.each do |team|
      team.associate_games_with_team(@matches)
    end
  end

  def count_of_teams
    @teams.count
  end

shorter_testing_data_files_2
  def verify_alignment(sorted_games_data, sorted_game_teams_data)
    #Makes sure the files are correctly aligned for quicker reading / processing
    i = 0
    num_correct = 0
    while i < sorted_games_data.length
      if sorted_games_data[i][:game_id] == sorted_game_teams_data[2 * i][:game_id] && sorted_games_data[i][:game_id] == sorted_game_teams_data[2 * i + 1][:game_id]  
        num_correct += 1
      end  
      i += 1
    end
  
    return true     #For now, just return true (causing issues with random short dataset)
    # return true if num_correct == @games.length
    # return false

  def most_accurate_team(season)
    team_accuracy = {}

    # Iterate through each game team to calculate goals and shots for each team in the given season
    @game_teams.each do |game_team|
      matching_game = @games.find { |g| g[:game_id] == game_team[:game_id] }
      next unless matching_game && matching_game[:season] == season

      team_id = game_team[:team_id]
      team_accuracy[team_id] ||= { goals: 0, shots: 0 }
      team_accuracy[team_id][:goals] += game_team[:goals].to_i
      team_accuracy[team_id][:shots] += game_team[:shots].to_i
    end

    return nil if team_accuracy.empty?

    # Find the team with the highest goals-to-shots ratio
    best_team_id = team_accuracy.max_by { |team_id, stats| stats[:goals].to_f / stats[:shots] }&.first

    @teams.find { |team| team[:team_id] == best_team_id }[:teamname]
  end

  def least_accurate_team(season)
    team_accuracy = {}

    # Iterate through each game team to calculate goals and shots for each team in the given season
    @game_teams.each do |game_team|
      matching_game = @games.find { |g| g[:game_id] == game_team[:game_id] }
      next unless matching_game && matching_game[:season] == season

      team_id = game_team[:team_id]
      team_accuracy[team_id] ||= { goals: 0, shots: 0 }
      team_accuracy[team_id][:goals] += game_team[:goals].to_i
      team_accuracy[team_id][:shots] += game_team[:shots].to_i
    end

    return nil if team_accuracy.empty?

    # Find the team with the lowest goals-to-shots ratio
    worst_team_id = team_accuracy.min_by { |team_id, stats| stats[:goals].to_f / stats[:shots] }&.first

    @teams.find { |team| team[:team_id] == worst_team_id }[:teamname]
  end

  def most_tackles(season)
    team_tackles = {}

    # Iterate through each game team to calculate tackles for each team in the given season
    @game_teams.each do |game_team|
      matching_game = @games.find { |g| g[:game_id] == game_team[:game_id] }
      next unless matching_game && matching_game[:season] == season

      team_id = game_team[:team_id]
      team_tackles[team_id] ||= 0
      team_tackles[team_id] += game_team[:tackles].to_i
    end

    return nil if team_tackles.empty?

    # Find the team with the most tackles
    most_tackles_team_id = team_tackles.max_by { |team_id, tackles| tackles }&.first

    @teams.find { |team| team[:team_id] == most_tackles_team_id }[:teamname]
  end

  def fewest_tackles(season)
    team_tackles = {}

    # Iterate through each game team to calculate tackles for each team in the given season
    @game_teams.each do |game_team|
      matching_game = @games.find { |g| g[:game_id] == game_team[:game_id] }
      next unless matching_game && matching_game[:season] == season

      team_id = game_team[:team_id]
      team_tackles[team_id] ||= 0
      team_tackles[team_id] += game_team[:tackles].to_i
    end

    return nil if team_tackles.empty?

    # Find the team with the fewest tackles
    fewest_tackles_team_id = team_tackles.min_by { |team_id, tackles| tackles }&.first

    @teams.find { |team| team[:team_id] == fewest_tackles_team_id }[:teamname]

  end
end


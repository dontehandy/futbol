require 'csv'

class StatTracker
  attr_reader :games, :teams, :game_teams

  def initialize()
    @games = []
    @teams = []
    @game_teams = []
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

  def average_goals_per_game()
    #Average over ALL games (and here total goals, i.e. away + home, is measured)
    total_goals = @games.sum do |game|
      game[:away_goals].to_i + game[:home_goals].to_i
    end

    # binding.pry

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

end

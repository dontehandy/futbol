require 'csv'
require 'pry'
require './lib/game'

class StatTracker
  attr_reader :games, :teams, :game_teams, :matches

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
    @games.count
  end

  def home_wins
    @games.count do |game|
      game[:away_goals] < game[:home_goals]
    end
  end

  def away_wins
    @games.count do |game|
      game[:away_goals] > game[:home_goals]
    end
  end

  def ties
    @games.count do |game|
      game[:away_goals] == game[:home_goals]
    end
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
    @matches = []
    @games.each do |game|
      @matches << Game.new(game, game_teams_home_data(game[:game_id]), game_teams_away_data(game[:game_id]))
    # break if @matches.length > 1000
    end
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


end

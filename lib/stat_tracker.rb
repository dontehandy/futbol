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
end

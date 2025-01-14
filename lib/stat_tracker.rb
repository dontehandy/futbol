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

end

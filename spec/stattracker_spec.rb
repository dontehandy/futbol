require 'spec_helper'
require 'csv' 

RSpec.describe StatTracker do
  # let(:locations) do
  #   {
  #     games: './data/games.csv',        
  #     teams: './data/teams.csv',        
  #     game_teams: './data/game_teams.csv' 
  #   }
  # end

  before(:all) do
    locations = {
      games: './data/games.csv',        
      teams: './data/teams.csv',        
      game_teams: './data/game_teams.csv' 
    }

    @stat_tracker = StatTracker.from_csv(locations)   #This now also builds the game objects (@matches) and team objects (@clubs)
  end
  
  before(:each) do
    # @stat_tracker = StatTracker.from_csv(locations)
    # @stat_tracker.create_all_games

    #Here's another instance with shorter datasets loaded for simpler testing:
    shorter_data_locations = {
      games: './data/short_test_games.csv',
      teams: './data/short_test_teams.csv',
      game_teams: './data/short_test_game_teams.csv',
    }
    @stat_tracker_short = StatTracker.from_csv(shorter_data_locations)
    # @stat_tracker_short.create_all_games

    # binding.pry

  end

  
  #Game Statistics methods

  describe '#highest_total_score' do
    it 'returns the highest total score from all games' do
      expect(@stat_tracker.highest_total_score).to eq(11)  
    end
  end
  
  describe '#lowest_total_score' do
    it 'returns the lowest total score from all games' do
      expect(@stat_tracker.lowest_total_score).to eq(0) 
    end
  end

  describe '#total_games' do
    it 'counts all games listed in game.csv file for game percentage stats' do
      expect(@stat_tracker.total_games).to eq(7441)
    end

    it 'counts all games listed in short_test_game.csv file for game percentage stats' do
      expect(@stat_tracker_short.total_games).to eq(20)
    end
  end

  describe '#home_wins' do
    it 'counts all the home wins from the short_test_games.csv accurately' do
      expect(@stat_tracker_short.home_wins).to eq(9)
    end
  end
  
  describe '#away_wins' do
    it 'counts all the away wins from the short_test_games.csv accurately' do
      expect(@stat_tracker_short.away_wins).to eq(8)
    end
  end

  describe '#ties' do
    it 'counts all the tied games from the short_test_games.csv accurately' do
      expect(@stat_tracker_short.ties).to eq(3)
    end
  end

  describe "#average_goals_per_game" do
    it "returns average goals per game over all seasons - from short_games.csv" do
      expect(@stat_tracker_short.average_goals_per_game()).to eq((90.0 / 20.0))     #90 total goals for 20 games in CSV file
    end

    it "returns average goals per game over all seasons - full data set" do
      #This is really what the Spec Harness should check
      expect(@stat_tracker.average_goals_per_game()).to eq(4.22)
    end
  end

  describe "#average_goals_by_season" do
    it "returns average goals per game for each season - from short_games.csv" do
      averages_hash = {
        "20122013" => (17.0 / 3.0).round(2),
        "20132014" => (21.0 / 5.0).round(2),
        "20142015" => (9.0 / 2.0).round(2),
        "20152016" => (14.0 / 3.0).round(2),
        "20162017" => (21.0 / 5.0).round(2),
        "20172018" => (8.0 / 2.0).round(2)
      }
      expect(@stat_tracker_short.average_goals_by_season()).to eq(averages_hash)
    end

    it "returns average goals per game for each season - full data set" do
      expect(@stat_tracker.average_goals_by_season()).to eq({"20122013"=>4.12, "20132014"=>4.19, "20142015"=>4.14, "20152016"=>4.16, "20162017"=>4.23, "20172018"=>4.44})
    end
  end

  describe "creates all games in a dataset" do
    it "returns all games in a smaller dataset" do
      expect(@stat_tracker_short.matches.length).to eq(20)
    end
  end


  describe '#highest_scoring_visitor' do
    it 'returns the team with the highest average score when visitor from short_games.csv' do
      expect(@stat_tracker_short.highest_scoring_visitor).to eq("Orlando City SC")
    end
  end

  describe '#count_of_games_by_season' do
    it 'returns a hash with season names as keys and counts of games as values' do
      expected = {
        "20122013" => 3,
        "20132014" => 5,
        "20142015" => 2,
        "20152016" => 3,
        "20162017" => 5,
        "20172018" => 2
      }
      expect(@stat_tracker_short.count_of_games_by_season).to eq(expected)

    end
  end

  describe '#highest_scoring_home' do
    it 'returns the team with the highest average score when home from short_games.csv' do
    expect(@stat_tracker_short.highest_scoring_home).to eq("Portland Thorns FC")
    end
  end

  describe '#lowest_scoring_home' do
    it 'returns the team with the lowest average score when home from short_games.csv' do
    expect(@stat_tracker_short.lowest_scoring_home).to eq("Utah Royals FC")
    end
  end

  describe '#lowest_scoring_home' do
    it 'returns the team with the lowest average score when home from short_games.csv' do
    expect(@stat_tracker_short.lowest_scoring_home).to eq("Utah Royals FC")
    end
  end

  describe '#count_of_teams' do
    it 'returns the count of teams' do
      expect(@stat_tracker.count_of_teams).to eq(32)
    end
  end

  describe '#offense ranks from short_games.csv' do
    it 'returns the team with highest average score' do
      expect(@stat_tracker_short.best_offense).to eq("Orlando City SC")

    end

    it 'returns the team with lowest average score' do
      expect(@stat_tracker_short.worst_offense).to eq("Chicago Red Stars")
    end
  end

  describe "#most_accurate_team" do
    it "returns the team with the highest shots-to-goals ratio for the season" do
      expect(@stat_tracker.most_accurate_team("20132014")).to eq "Real Salt Lake"
      expect(@stat_tracker.most_accurate_team("20142015")).to eq "Toronto FC"
    end

    it "returns the team with the highest shots-to-goals ratio for the season from short_games.csv" do
      expect(@stat_tracker_short.most_accurate_team("20132014")).to eq nil 
      expect(@stat_tracker_short.most_accurate_team("20142015")).to eq nil 
    end
  end
end


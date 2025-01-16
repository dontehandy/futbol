require 'rspec'
require 'csv'
require './lib/stat_tracker'
require 'pry'

RSpec.describe StatTracker do
  let(:locations) do
    {
      games: './data/games.csv',        
      teams: './data/teams.csv',        
      game_teams: './data/game_teams.csv' 
    }
  end

  before(:each) do
    @stat_tracker = StatTracker.from_csv(locations)

    #Here's another instance with shorter datasets loaded for simpler testing:
    # shorter_data_locations = {
    #   games: './data/short_games.csv',
    #   teams: './data/short_teams.csv',
    #   game_teams: './data/short_game_teams.csv',
    # }
    # @stat_tracker_short = StatTracker.from_csv(shorter_data_locations)
  end

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

  describe "#average_goals_per_game" do
    xit "returns average goals per game over all seasons - from short_games.csv" do
      #Enable this once small data set available
      expect(@stat_tracker_short.average_goals_per_game()).to eq((90.0 / 20.0))
    end

    it "returns average goals per game over all seasons - full data set" do
      #This is really what the Spec Harness should check
      expect(@stat_tracker.average_goals_per_game()).to eq(4.22)
    end
  end

  describe "#average_goals_by_season" do
    xit "returns average goals per game for each season - from short_games.csv" do
      #Enable this once small data set available
      expect(@stat_tracker_short.average_goals_by_season()).to eq()
    end

    it "returns average goals per game for each season - full data set" do
      expect(@stat_tracker.average_goals_by_season()).to eq({"20122013"=>4.12, "20132014"=>4.19, "20142015"=>4.14, "20152016"=>4.16, "20162017"=>4.23, "20172018"=>4.44})
    end
  end
  
end


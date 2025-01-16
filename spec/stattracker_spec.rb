require 'rspec'
require 'csv'
require './lib/stat_tracker'

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
  
end


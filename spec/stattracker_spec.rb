require 'spec_helper'
require 'csv' 

RSpec.describe StatTracker do
  before(:all) do
    locations = {
      games: './data/games.csv',        
      teams: './data/teams.csv',        
      game_teams: './data/game_teams.csv' 
    }

    @stat_tracker = StatTracker.from_csv(locations)
  end
  
  before(:each) do
    shorter_data_locations = {
      games: './data/short_test_games.csv',
      teams: './data/teams.csv',
      game_teams: './data/short_test_game_teams.csv',
    }
    @stat_tracker_short = StatTracker.from_csv(shorter_data_locations)
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
      expect(@stat_tracker_short.average_goals_per_game()).to eq((40.0 / 12.0).round(2))
    end

    it "returns average goals per game over all seasons - full data set" do
      expect(@stat_tracker.average_goals_per_game()).to eq(4.22)
    end
  end

  describe "#average_goals_by_season" do
    it "returns average goals per game for each season - from short_games.csv" do
      averages_hash = {
        "20132014" => (8.0 / 3.0).round(2),
        "20142015" => (9.0 / 3.0).round(2),
        "20152016" => (9.0 / 3.0).round(2),
        "20162017" => (5.0 / 1.0).round(2),
        "20172018" => (9.0 / 2.0).round(2)
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
      expect(@stat_tracker_short.highest_scoring_visitor).to eq("Seattle Sounders FC")
    end
  end

  describe '#count_of_games_by_season' do
    it 'returns a hash with season names as keys and counts of games as values' do
      expected = {
        "20132014" => 3,
        "20142015" => 3,
        "20152016" => 3,
        "20162017" => 1,
        "20172018" => 2
      }
      expect(@stat_tracker_short.count_of_games_by_season).to eq(expected)

    end
  end

  describe '#highest_scoring_home' do
    it 'returns the team with the highest average score when home from short_games.csv' do
    expect(@stat_tracker_short.highest_scoring_home).to eq("Houston Dynamo")
    end
  end

  describe '#lowest_scoring_home' do
    it 'returns the team with the lowest average score when home from short_games.csv' do
    expect(@stat_tracker_short.lowest_scoring_home).to eq("Philadelphia Union")
    end
  end

  describe '#lowest_scoring_home' do
    it 'returns the team with the lowest average score when home from short_games.csv' do
    expect(@stat_tracker_short.lowest_scoring_home).to eq("Philadelphia Union")
    end
  end

  describe '#count_of_teams' do
    it 'returns the count of teams' do
      expect(@stat_tracker.count_of_teams).to eq(32)
    end
  end

  describe '#offense ranks from short_games.csv' do
    it 'returns the team with highest average score' do
      expect(@stat_tracker_short.best_offense).to eq("Seattle Sounders FC")

    end

    it 'returns the team with lowest average score' do
      expect(@stat_tracker_short.worst_offense).to eq("Philadelphia Union")
    end
  end

  describe '#most_accurate_team' do
    before do
      @game_teams = [
        { game_id: '2014020651', team_id: '52', goals: '2', shots: '5' },
        { game_id: '2014020651', team_id: '25', goals: '1', shots: '11' }
      ]

      @games = [
        { game_id: '2014020651', season: '20142015' }
      ]

      @teams = [
        { team_id: '52', teamname: 'Portland Thorns FC' },
        { team_id: '25', teamname: 'Chicago Red Stars' }
      ]

      allow(@stat_tracker_short).to receive(:game_teams).and_return(@game_teams)
      allow(@stat_tracker_short).to receive(:games).and_return(@games)
      allow(@stat_tracker_short).to receive(:teams).and_return(@teams)
    end

    it 'returns the team with the highest shots-to-goals ratio for the season' do
      expect(@stat_tracker_short.most_accurate_team('20142015')).to eq('Portland Thorns FC')
    end

    it 'returns nil if no data matches the season' do
      expect(@stat_tracker_short.most_accurate_team('20202021')).to be_nil
    end
  end

  describe '#least_accurate_team' do
    before do
      @game_teams = [
        { game_id: '2014020651', team_id: '52', goals: '2', shots: '5' },
        { game_id: '2014020651', team_id: '25', goals: '1', shots: '11' }
      ]

      @games = [
        { game_id: '2014020651', season: '20142015' }
      ]

      @teams = [
        { team_id: '52', teamname: 'Portland Thorns FC' },
        { team_id: '25', teamname: 'Utah Royals FC' }
      ]

      allow(@stat_tracker_short).to receive(:game_teams).and_return(@game_teams)
      allow(@stat_tracker_short).to receive(:games).and_return(@games)
      allow(@stat_tracker_short).to receive(:teams).and_return(@teams)
    end

    it 'returns the team with the lowest shots-to-goals ratio for the season' do
      expect(@stat_tracker_short.least_accurate_team('20142015')).to eq('Utah Royals FC')
    end

    it 'returns nil if no data matches the season' do
      expect(@stat_tracker_short.least_accurate_team('20202021')). to be_nil
    end
  end

  describe '#most_tackles' do
    before do
      @game_teams = [
        { game_id: '2014020651', team_id: '52', tackles: '34' },
        { game_id: '2014020651', team_id: '25', tackles: '23' }
      ]

      @games = [
        { game_id: '2014020651', season: '20142015' }
      ]

      @teams = [
        { team_id: '52', teamname: 'Portland Thorns FC' },
        { team_id: '25', teamname: 'North Carolina Courage' }
      ]

      allow(@stat_tracker_short).to receive(:game_teams).and_return(@game_teams)
      allow(@stat_tracker_short).to receive(:games).and_return(@games)
      allow(@stat_tracker_short).to receive(:teams).and_return(@teams)
    end

    it 'returns the team with the most tackles for the season' do
      expect(@stat_tracker_short.most_tackles('20142015')).to eq('North Carolina Courage')
    end

    it 'returns nil if no data matches the season' do
      expect(@stat_tracker_short.most_tackles('20202021')). to be_nil
    end
  end

  describe '#fewest_tackles' do
    before do
      @game_teams = [
        { game_id: '2014020651', team_id: '52', tackles: '34' },
        { game_id: '2014020651', team_id: '25', tackles: '23' }
      ]

      @games = [
        { game_id: '2014020651', season: '20142015' }
      ]

      @teams = [
        { team_id: '52', teamname: 'Portland Thorns FC' },
        { team_id: '25', teamname: 'LA Galaxy' }
      ]

      allow(@stat_tracker_short).to receive(:game_teams).and_return(@game_teams)
      allow(@stat_tracker_short).to receive(:games).and_return(@games)
      allow(@stat_tracker_short).to receive(:teams).and_return(@teams)
    end

    it 'returns the team with the fewest tackles for the season' do
      expect(@stat_tracker_short.fewest_tackles('20132014')).to eq('LA Galaxy')
    end

    it 'returns nil if no data matches the season' do
      expect(@stat_tracker_short.fewest_tackles('20202021')). to be_nil
    end
  end
end


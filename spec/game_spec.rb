require 'spec_helper.rb'

RSpec.describe Game do
  before(:all) do
    shorter_data_locations = {
      games: './data/short_test_games.csv',
      teams: './data/teams.csv',
      game_teams: './data/short_test_game_teams.csv',
    }
    @stat_tracker_short = StatTracker.from_csv(shorter_data_locations)
  end

  it 'can initialize all game data' do
    #Choose one random game to verify all data is set appropriately
    random_game = @stat_tracker_short.matches[9]

    expect(random_game).to be_a(Game)
    #Info from games.csv
    expect(random_game.game_id).to eq("2016021087")
    expect(random_game.season).to eq("20162017")
    expect(random_game.type).to eq("Regular Season")
    expect(random_game.date_time).to eq("3/23/17")
    expect(random_game.game_stats[:away][:team_id]).to eq(2)
    expect(random_game.game_stats[:home][:team_id]).to eq(3)
    expect(random_game.game_stats[:away][:goals]).to eq(3)
    expect(random_game.game_stats[:home][:goals]).to eq(2)
    #Info imported from short_test_game_teams.csv:
    expect(random_game.game_stats[:away][:result]).to eq("WIN")
    expect(random_game.game_stats[:away][:head_coach]).to eq("Doug Weight")
    expect(random_game.game_stats[:away][:shots]).to eq(7)
    expect(random_game.game_stats[:away][:tackles]).to eq(25)
    expect(random_game.game_stats[:home][:result]).to eq("LOSS")
    expect(random_game.game_stats[:home][:head_coach]).to eq("Alain Vigneault")
    expect(random_game.game_stats[:home][:shots]).to eq(9)
    expect(random_game.game_stats[:home][:tackles]).to eq(25)
  end

  it 'can properly assign two teams to the game' do
    random_game = @stat_tracker_short.matches[9]
    #Locate the actual team objects for comparison later
    random_game.associate_teams_with_game(@stat_tracker_short.clubs)
    right_away_team = @stat_tracker_short.clubs.find do |team|
      team.team_id.to_i == random_game.game_stats[:away][:team_id]
    end
    right_home_team = @stat_tracker_short.clubs.find do |team|
      team.team_id.to_i == random_game.game_stats[:home][:team_id]
    end

    expect(random_game.game_stats[:away][:team]).to eq(right_away_team)
    expect(random_game.game_stats[:home][:team]).to eq(right_home_team)
    expect(random_game.game_stats[:away][:team].team_name).to eq("Seattle Sounders FC")
    expect(random_game.game_stats[:home][:team].team_name).to eq("Houston Dynamo")
  end

end
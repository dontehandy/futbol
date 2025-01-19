require 'spec_helper.rb'

RSpec.describe Team do
  before(:all) do
    shorter_data_locations = {
      games: './data/short_test_games.csv',
      teams: './data/teams.csv',
      game_teams: './data/short_test_game_teams.csv',
    }
    @stat_tracker_short = StatTracker.from_csv(shorter_data_locations)

    sample_team_data_hash = {team_id: 100, teamname: "Test Team"}
    @new_team = Team.new(sample_team_data_hash)
  end

  it "can initialize properly" do
    expect(@new_team).to be_a(Team)
    expect(@new_team.team_id).to eq(100)
    expect(@new_team.team_name).to eq("Test Team")
    expect(@new_team.games_played).to eq([])

    random_team = @stat_tracker_short.clubs[14]

    expect(random_team).to be_a(Team)
    expect(random_team.team_id).to eq(30)
    expect(random_team.team_name).to eq("Orlando City SC")
    # expect(random_team.games_played).to eq([])
  end

  it "can determine all games given team has played in" do
    #Make a list of a few misc games
    misc_games = []
    misc_games << @stat_tracker_short.matches[3]
    misc_games << @stat_tracker_short.matches[8]
    misc_games << Game.new({home_team_id: 100}, {head_coach: "Test Coach1"}, {})
    misc_games << Game.new({away_team_id: 100}, {head_coach: "Test Coach1"}, {})

    @new_team.associate_games_with_team(misc_games)
    expect(@new_team.games_played.length).to eq(2)
    expect(@new_team.games_played).to eq([misc_games[2], misc_games[3]])

    random_team = @stat_tracker_short.clubs[14]

    # game1_hash = {}

    # binding.pry

    # random_team.associate_games_with_team(@stat_tracker_short.matches)

    # binding.pry

    expect(random_team.games_played.length).to eq(1)
    expect(random_team.games_played[0].game_stats[:away][:head_coach]).to eq("Mike Yeo")
    #And one more

  end
  
end

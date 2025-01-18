#This is just a draft for the class.  A few notes:
# - instance variables and organization: made sense to me, but adjustments are welcome
# - methods: I only included the bare minimum (don't want to bias us too much on direction), but can provide more if interested
# - we need a way to create these game objects (and separately team objects).  Could do that from the StatTracker class (like a 'factory'),
#     which could build them by reading from the raw data variables (@games, @teams, @game_teams)?
# - I have left out instance variables from the raw data that it doesn't look like we'll use (venue, pim, etc.)  These can be added if needed, of course.

class Game
  attr_reader :game_id, :season, :type, :date_time, :game_stats

  def initialize(game_data, game_teams_home_data, game_teams_away_data)
    #IMPORTANT: game_data, game_teams_data are data for ONLY THIS game - needs to be selected before passing in!
    #Each game only needs some of the raw data
    #Access it similar to a hash (it is of CSV format, though .to_h and .to_a work as well)
    @game_id = game_data[:game_id]
    @season = game_data[:season]
    @type = game_data[:type]
    @date_time = game_data[:date_time]

    #NOTE: starting here, these variables seem like they will never be used in the project (no StatTracker method will need them, methinks?)
    # @home_pim           #WTF is PIM? Penalty Minutes :^)
    # @away_pim
    # @home_power_play_opps
    # @away_power_play_opps
    # @home_power_play_goals
    # @away_power_play_goals
    # @home_face_off_win_percentage
    # @away_face_off_win_percentage
    # @home_giveaways
    # @away_giveaways
    # @home_takeaways
    # @away_takeaways

    #This stores home + away values in a hash for compactness.  Again, open to adjustments if helpful.
    #As an example, to access a value, like home team goals for this game, would look like this:
    #@game_stats[:home][:goals]
    @game_stats = {
      :home => {team: nil,                          #The team objects need to be associated with their respective teams (by id) once the team objects are built
        team_id: game_data[:home_team_id].to_i,
        goals: game_data[:home_goals].to_i,
        result: game_teams_home_data[:result],
        head_coach: game_teams_home_data[:head_coach],
        shots: game_teams_home_data[:shots].to_i,
        tackles: game_teams_home_data[:tackles].to_i},
      :away => {team: nil,
        team_id: game_data[:away_team_id].to_i,
        goals: game_data[:away_goals].to_i,
        result: game_teams_away_data[:result],
        head_coach: game_teams_away_data[:head_coach],
        shots: game_teams_away_data[:shots].to_i,
        tackles: game_teams_away_data[:tackles].to_i}
    }
    
    #Once the team objects (from Team class) are built, we can run:
    # associate_teams_with_game(all_teams), where all_teams is an array of all the team objects (tracked in StatTracker maybe?)
    #Now, @game_stats[:home][:team] will be the actual home team object for this game (and same for away team var)
  end

  def associate_teams_with_game(all_teams)
    #NOTE: requires all_teams to be built array of teams (i.e. must have been initialized and constructed first!)
    #Locate teams associated with given IDs for easier future reference
    return nil if !all_teams || all_teams.length == 0

    @game_stats[:away][:team] = all_teams.find do |team|
      team.team_id.to_i == @game_stats[:away][:team_id]
    end
    @game_stats[:home][:team] = all_teams.find do |team|
      team.team_id.to_i == @game_stats[:home][:team_id]
    end
  end

end
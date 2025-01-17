class Team
  attr_reader :team_id, :team_name

  def initialize(team_data)
    @team_id = team_data[:team_id]
    @team_name = team_data[:teamName]
  end
end
   

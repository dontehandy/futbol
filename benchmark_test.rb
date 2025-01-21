require 'benchmark'
require_relative './lib/stat_tracker'

# ruby /Users/dontehandy/turing_work/1mod/projects/futbol/benchmark_test.rb

def run_benchmark(stat_tracker)
  results = Benchmark.bm do |bm|
    bm.report("highest_total_score") { stat_tracker.highest_total_score }
    bm.report("lowest_total_score") { stat_tracker.lowest_total_score }
    bm.report("percentage_home_wins") { stat_tracker.percentage_home_wins }
    bm.report("percentage_visitor_wins") { stat_tracker.percentage_visitor_wins }
    bm.report("percentage_ties") { stat_tracker.percentage_ties }
    bm.report("total_games") { stat_tracker.total_games }
    bm.report("home_wins") { stat_tracker.home_wins }
    bm.report("away_wins") { stat_tracker.away_wins }
    bm.report("ties") { stat_tracker.ties }
    bm.report("average_goals_per_game") { stat_tracker.average_goals_per_game }
    bm.report("average_goals_by_season") { stat_tracker.average_goals_by_season }
    bm.report("count_of_games_by_season") { stat_tracker.count_of_games_by_season }
    bm.report("best_offense") { stat_tracker.best_offense }
    bm.report("worst_offense") { stat_tracker.worst_offense }
    bm.report("highest_scoring_visitor") { stat_tracker.highest_scoring_visitor }
    bm.report("highest_scoring_home") { stat_tracker.highest_scoring_home }
    bm.report("lowest_scoring_home") { stat_tracker.lowest_scoring_home }
    bm.report("lowest_scoring_visitor") { stat_tracker.lowest_scoring_visitor }
    bm.report("most_accurate_team") { stat_tracker.most_accurate_team('20142015') }
    bm.report("least_accurate_team") { stat_tracker.least_accurate_team('20142015') }
    bm.report("most_tackles") { stat_tracker.most_tackles('20142015') }
    bm.report("fewest_tackles") { stat_tracker.fewest_tackles('20142015') }
    bm.report("winningest_coach") { stat_tracker.winningest_coach('20142015') }
    bm.report("worst_coach") { stat_tracker.worst_coach('20142015') }
  end

  # Print results in order of speed
  sorted_results = results.sort_by { |result| result.real }
  sorted_results.each do |result|
    puts "#{result.label}: #{result.real.round(6)} seconds"
  end
end

def run_all_benchmarks
  stat_tracker = StatTracker.from_csv({
    games: './data/games.csv',
    teams: './data/teams.csv',
    game_teams: './data/game_teams.csv'
  })

  puts "Running built-in Benchmark..."
  run_benchmark(stat_tracker)
end

# Run all benchmarks
run_all_benchmarks
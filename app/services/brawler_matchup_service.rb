class BrawlerMatchupService
  def initialize(brawler)
    @brawler = brawler
  end

  def analyze_matchups
    ActiveRecord::Base.connection.execute(matchup_analysis_query).to_a
  end

  private

  def matchup_analysis_query
    <<-SQL
      WITH brawler_stats AS (
        SELECT
          tp.brawler_id,
          ROUND(AVG(tp.power)::NUMERIC, 2) AS avg_power,
          ROUND(AVG(tp.trophies)::NUMERIC, 2) AS avg_trophies
        FROM
          team_players tp
        WHERE
          tp.brawler_id = #{@brawler.id}
        GROUP BY
          tp.brawler_id
      ),
      filtered_battles AS (
        SELECT
          t.battle_id,
          t.result AS brawler_team_result,
          tp.team_id AS brawler_team_id,
          opp_tp.team_id AS opponent_team_id
        FROM
          teams t
        JOIN
          team_players tp ON tp.team_id = t.id AND tp.brawler_id = #{@brawler.id}
        JOIN
          teams opp_t ON opp_t.battle_id = t.battle_id AND opp_t.id != t.id
        JOIN
          team_players opp_tp ON opp_tp.team_id = opp_t.id
      ),
      opponent_stats AS (
        SELECT
          fb.battle_id,
          fb.brawler_team_result,
          opp_tp.brawler_id AS opponent_brawler_id,
          brawlers.name AS opponent_brawler_name,
          brawlers.brawl_stars_id AS opponent_brawl_stars_id,
          ROUND(AVG(opp_tp.power)::NUMERIC, 2) AS opponent_avg_power,
          ROUND(AVG(opp_tp.trophies)::NUMERIC, 2) AS opponent_avg_trophies
        FROM
          filtered_battles fb
        JOIN
          team_players opp_tp ON fb.opponent_team_id = opp_tp.team_id
        JOIN
          brawlers ON opp_tp.brawler_id = brawlers.id
        GROUP BY
          fb.battle_id, fb.brawler_team_result, opp_tp.brawler_id, brawlers.name, brawlers.brawl_stars_id
      ),
      win_rates AS (
        SELECT
          os.opponent_brawler_id,
          os.opponent_brawler_name,
          os.opponent_brawl_stars_id,
          COUNT(CASE WHEN os.brawler_team_result = 1 THEN 1 END) AS wins,
          COUNT(*) AS total_battles,
          ROUND((COUNT(CASE WHEN os.brawler_team_result = 1 THEN 1 END) * 100.0) / COUNT(*), 2) AS win_rate,
          ROUND(AVG(os.opponent_avg_power)::NUMERIC, 2) AS avg_opponent_power,
          ROUND(AVG(os.opponent_avg_trophies)::NUMERIC, 2) AS avg_opponent_trophies
        FROM
          brawler_stats bs
        JOIN
          opponent_stats os ON
            os.opponent_avg_power BETWEEN bs.avg_power * 0.85 AND bs.avg_power * 1.15
            AND os.opponent_avg_trophies BETWEEN bs.avg_trophies * 0.85 AND bs.avg_trophies * 1.15
        GROUP BY
          os.opponent_brawler_id, os.opponent_brawler_name, os.opponent_brawl_stars_id
      )
      SELECT
        opponent_brawler_id,
        opponent_brawler_name,
        opponent_brawl_stars_id,
        wins,
        total_battles,
        win_rate,
        avg_opponent_power,
        avg_opponent_trophies
      FROM
        win_rates
      ORDER BY
        win_rate DESC, total_battles DESC;
    SQL
  end
end 
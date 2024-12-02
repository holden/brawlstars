# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_02_100349) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "battles", force: :cascade do |t|
    t.string "battle_time", null: false
    t.string "battle_type"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id", null: false
    t.index ["battle_time"], name: "index_battles_on_battle_time"
    t.index ["event_id"], name: "index_battles_on_event_id"
  end

  create_table "brawlers", force: :cascade do |t|
    t.string "name"
    t.integer "brawl_stars_id", null: false
    t.string "rarity"
    t.string "brawler_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brawl_stars_id"], name: "index_brawlers_on_brawl_stars_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.integer "brawl_stars_id", null: false
    t.bigint "map_id", null: false
    t.bigint "mode_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brawl_stars_id"], name: "index_events_on_brawl_stars_id", unique: true
    t.index ["map_id"], name: "index_events_on_map_id"
    t.index ["mode_id"], name: "index_events_on_mode_id"
  end

  create_table "maps", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_maps_on_name", unique: true
  end

  create_table "modes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_modes_on_name", unique: true
  end

  create_table "player_brawlers", force: :cascade do |t|
    t.bigint "player_id"
    t.integer "brawler_id", null: false
    t.integer "power"
    t.integer "rank"
    t.integer "trophies"
    t.integer "highest_trophies"
    t.jsonb "gears", default: []
    t.jsonb "star_powers", default: []
    t.jsonb "gadgets", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brawler_id"], name: "index_player_brawlers_on_brawler_id"
    t.index ["player_id", "brawler_id"], name: "index_player_brawlers_on_player_id_and_brawler_id", unique: true
    t.index ["player_id"], name: "index_player_brawlers_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "country_id"
    t.string "tag", null: false
    t.string "name"
    t.string "club_name"
    t.integer "current_rank"
    t.integer "current_trophies"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "icon_id"
    t.integer "highest_trophies"
    t.integer "exp_level"
    t.integer "exp_points"
    t.boolean "is_qualified_from_championship", default: false
    t.integer "victories_3vs3"
    t.integer "solo_victories"
    t.integer "duo_victories"
    t.integer "best_robo_rumble_time"
    t.integer "best_time_as_big_brawler"
    t.string "club_tag"
    t.index ["country_id"], name: "index_players_on_country_id"
    t.index ["current_rank"], name: "index_players_on_current_rank"
    t.index ["current_trophies"], name: "index_players_on_current_trophies"
    t.index ["tag"], name: "index_players_on_tag", unique: true
  end

  create_table "team_players", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "player_id"
    t.string "player_tag", null: false
    t.bigint "brawler_id", null: false
    t.boolean "is_star_player", default: false, null: false
    t.integer "power", default: 1, null: false
    t.integer "trophies", default: 0, null: false
    t.jsonb "gears", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brawler_id", "team_id"], name: "index_team_players_on_brawler_id_and_team_id"
    t.index ["brawler_id"], name: "index_team_players_on_brawler_id"
    t.index ["player_id"], name: "index_team_players_on_player_id"
    t.index ["player_tag"], name: "index_team_players_on_player_tag"
    t.index ["team_id"], name: "index_team_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "battle_id", null: false
    t.integer "rank", null: false
    t.integer "result", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battle_id", "rank"], name: "index_teams_on_battle_id_and_rank"
    t.index ["battle_id", "result"], name: "index_teams_on_battle_id_and_result"
    t.index ["battle_id"], name: "index_teams_on_battle_id"
  end

  add_foreign_key "battles", "events"
  add_foreign_key "events", "maps"
  add_foreign_key "events", "modes"
  add_foreign_key "player_brawlers", "players"
  add_foreign_key "team_players", "brawlers"
  add_foreign_key "team_players", "players"
  add_foreign_key "team_players", "teams"
  add_foreign_key "teams", "battles"
end

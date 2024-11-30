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

ActiveRecord::Schema[8.0].define(version: 2024_11_30_150446) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "brawlers", force: :cascade do |t|
    t.string "name"
    t.integer "brawl_stars_id", null: false
    t.string "rarity"
    t.string "brawler_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brawl_stars_id"], name: "index_brawlers_on_brawl_stars_id", unique: true
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

  add_foreign_key "player_brawlers", "players"
end

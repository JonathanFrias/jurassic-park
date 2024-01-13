class CreateCagesAndDinosaurs < ActiveRecord::Migration[7.1]
  def change
    create_table "cages", force: :cascade do |t|
      t.string "name"
      t.string "status", default: "down"
      t.integer :dinosaurs_count, default: 0
      t.integer :capacity, default: 10
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "dinosaurs", force: :cascade do |t|
      t.string "name"
      t.integer "cage_id", null: false
      t.string "diet"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["cage_id"], name: "index_dinosaurs_on_cage_id"
    end

    add_foreign_key "dinosaurs", "cages"
  end
end

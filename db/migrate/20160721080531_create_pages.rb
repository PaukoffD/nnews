class CreatePages < ActiveRecord::Migration
  def change
   create_table :pages do |t|
    t.string   "title"
    t.string   "ref"
    t.time     "time"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "source_id",   default: 0
    t.string   "summary"
    t.integer  "category_id", default: 0
    t.string   "image"
    end
    add_index "pages", ["ref"], name: "index_pages_on_ref", unique: true
  end
end

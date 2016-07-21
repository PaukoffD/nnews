class CreateSources < ActiveRecord::Migration
  def change
   create_table :sources do |t|
    t.string   "name"
    t.string   "ref"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "count"
    t.text     "type"
    t.boolean  "html"
    end
  end
end

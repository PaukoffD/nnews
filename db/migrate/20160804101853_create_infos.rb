class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.integer :source_id
      t.datetime "data"
      t.integer  "size"
      t.integer  :page_count
      t.integer  :tag_count
      t.integer  :tagging

      t.timestamps null: false

    end
    add_index :infos, [:source_id, :data], unique: true
  end
end

class CreatePagematches < ActiveRecord::Migration[5.0]
  def change
    create_table :pagematches do |t|
      t.integer :page_id
      t.integer :match_id

      t.timestamps
    end
  end
end

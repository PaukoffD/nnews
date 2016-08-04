class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :source_id
      t.string :name
      t.integer :count

      t.timestamps null: false
    end
  end
end

class CreateTagexcepts < ActiveRecord::Migration
  def change
    create_table :tagexcepts do |t|
      t.string :name

      t.timestamps null: false
    end
    add_index :tagexcepts, :name, unique: true
  end
end

class CreateTagoverlaps < ActiveRecord::Migration
  def change
    create_table :tagoverlaps do |t|
      t.string :name
      t.string :nametarget

      t.timestamps null: false
    end
   add_index :tagoverlaps, :name, unique: true
   add_index :tagoverlaps, :nametarget 
  end
end

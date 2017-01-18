class AddTaggsToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :taggs, :string, default: ""
    add_column :pages, :cnt_match, :integer, default: 0
    add_column :pages, :flag_match,:boolean, default: false
  end
end

class AddDuplToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :dupl, :boolean, default: false
  end
end

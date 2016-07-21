class ChangeColumnFromPages < ActiveRecord::Migration
  def change
  	change_column :pages, :time, :datetime
  end
end

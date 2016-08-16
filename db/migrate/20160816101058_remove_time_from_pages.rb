class RemoveTimeFromPages < ActiveRecord::Migration
  def change
  	remove_column :pages, :time, :published 
  end
end

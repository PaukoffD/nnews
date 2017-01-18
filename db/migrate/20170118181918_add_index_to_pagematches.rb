class AddIndexToPagematches < ActiveRecord::Migration[5.0]
  def change
  	add_column :pagematches, :koef, :float
  end
  add_index "pagematches", ["page_id", "match_id"], name: "index_pagematches", unique: true
 
end

# == Schema Information
#
# Table name: tagoverlaps
#
#  id         :integer          not null, primary key
#  name       :string
#  nametarget :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tagoverlaps_on_name        (name) UNIQUE
#  index_tagoverlaps_on_nametarget  (nametarget)
#

class Tagoverlap < ActiveRecord::Base
	 validates :name, uniqueness: true
end

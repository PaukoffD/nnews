# == Schema Information
#
# Table name: tagexcepts
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tagexcepts_on_name  (name) UNIQUE
#

class Tagexcept < ActiveRecord::Base
	 validates :name, uniqueness: true
end

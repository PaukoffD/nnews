# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  source_id  :integer
#  name       :string
#  count      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ActiveRecord::Base
end

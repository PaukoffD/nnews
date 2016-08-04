# == Schema Information
#
# Table name: infos
#
#  id         :integer          not null, primary key
#  source_id  :integer
#  data       :datetime
#  size       :integer
#  page_count :integer
#  tag_count  :integer
#  tagging    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_infos_on_source_id_and_data  (source_id,data) UNIQUE
#

class Info < ActiveRecord::Base
	belongs_to :source, inverse_of: :infos
end

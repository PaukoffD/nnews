# == Schema Information
#
# Table name: pagematches
#
#  id         :integer          not null, primary key
#  page_id    :integer
#  match_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Pagematch < ApplicationRecord
end

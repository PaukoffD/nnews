# == Schema Information
#
# Table name: sources
#
#  id                  :integer          not null, primary key
#  name                :string
#  ref                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  avatar_file_name    :string
#  avatar_content_type :string
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#  count               :integer
#  type                :text
#  html                :boolean
#


require "rails_helper"

describe Source, type: :model do
 
  it { is_expected.to have_many(:pages) }

  
end

# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  title       :string
#  ref         :string
#  time        :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          default(0)
#  summary     :string
#  category_id :integer          default(0)
#  image       :string
#


require "rails_helper"

describe Page, type: :model do
 
  it { is_expected.to belong_to(:source) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:time) }
   context "unique" do
    #subject { build(:ref) }
    it { is_expected.to validate_uniqueness_of(:ref) }
  end
end

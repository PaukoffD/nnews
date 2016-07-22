
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
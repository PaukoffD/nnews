
require "rails_helper"

RSpec.describe Page, type: :model do
 
 describe Page do
  it { is_expected.to belong_to(:source) }
  #it { is_expected.to validate_presence_of(:ref) }
   context "unique" do
    subject { build(:ref) }
    it { is_expected.to validate_uniqueness_of(:ref).case_insensitive }
  end
 end
end
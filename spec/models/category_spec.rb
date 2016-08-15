require 'rails_helper'

describe Category, type: :model do
 
  it { is_expected.to have_many(:pages) }
  
   context "unique" do
    #subject { build(:ref) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end

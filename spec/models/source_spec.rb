
require "rails_helper"

describe Source, type: :model do
 
  it { is_expected.to have_many(:pages) }

  
end
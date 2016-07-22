class Page < ActiveRecord::Base
  belongs_to :source
  validates  :title, presence: true
  validates  :time,  presence: true
  validates :ref, uniqueness: true # validates_uniqueness_of :title, conditions: -> { where.not(status: 'archived') }
  acts_as_taggable_on :tags

  self.per_page = 1000
end

class Source < ActiveRecord::Base
  has_many :pages, dependent: :destroy
  has_many :infos, inverse_of: :source
  accepts_nested_attributes_for :infos
  has_attached_file :avatar, styles: { medium: '300x300>', thumb: '100x100>, :png', original: ['500x500>', :png] },
                             convert_options: { thumb: '-quality 75 -strip', medium: '-quality 75 -strip', original: '-quality 85 -strip' },
                             default_url: '/images/:style/missing.png'
  validates_attachment_content_type :avatar, size: { in: 0..500.kilobytes }, content_type: /\Aimage\/.*\Z/
  #has_paper_trail

  scope :rss, -> { where html: false }
  scope :html,-> { where html: true }


 def last
 infos.order(:data).first
 end

 def source
 infos.order(:source_id).last
 end
end

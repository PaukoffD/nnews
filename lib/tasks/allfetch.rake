task allfetch: :environment do
  ActsAsTaggableOn.delimiter = [' ', ',']

  @pages = Page.joins(:taggings)
  # @pages = Page.where("pages.id > ? ",tmp1 )
  # loa
  tgs = Tagexcept.all
  @pages.each do |pt|
    str = pt.tag_list.add(pt.title, parse: true)

    pt.save
  end
end

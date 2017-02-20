module PagesHelper

  def analyzerss
    @feed=[]
    @feedname=[] 
    @feedurl=[] 
    @source.rss.each do |a|
      url=a.ref
      feed = Feedjira::Feed.fetch_and_parse url
      @feedname << a.name
      @feedurl << a.ref
      @feed <<   feed.entries.first.to_a
    end
  end

end

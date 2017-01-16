class FeedPresenter

  def initialize(source = nil)
    @source = source
    @feed=[]
  end

  def show
    
    @feeds=[]
    @feed.each do |f|
      @feeds <<f
    end
  end

  def caption
    
    @source.rss.each do |a| 
      url=a.ref 
      feed = Feedjira::Feed.fetch_and_parse url 
      #@feedname= a.name 
      #@feedurl=a.ref 
      #feed.entries.first.to_a 
      @feed <<   feed.entries.first.to_a 
    end
    #feeds
  end

  # ... Other presenter methods

  def method_missing(method)
    @feed.send(method) rescue nil
  end
end

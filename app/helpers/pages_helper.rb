module PagesHelper

  def analyzerss
    @feed=[]
    @feedname=[] 
    @feedurl=[] 
    @source.rss.each do |a|
      url=a.ref
      begin
        feed = Feedjira::Feed.fetch_and_parse url
      rescue Feedjira::FetchFailure => e
        Rails.logger.error e.message
        next
      rescue Feedjira::NoParserAvailable => e
        Rails.logger.error e.message
        next
      end
      @feedname << a.name
      @feedurl << a.ref
      @feed <<   feed.entries.first.to_a
    end
  end

end

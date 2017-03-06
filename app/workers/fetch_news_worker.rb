class FetchNewsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # Important!
  
  
  def perform(sources,count)
    source = Source.all
    source.rss.each do |s|
      url = s.ref
      puts url
      feed = Feedjira::Feed.fetch_and_parse url
      feed.entries.each do |entry|
        puts entry.title
        @p = Page.new
        @p.title = entry.title
        @p.ref = entry.url
        @p.time = entry.published.to_datetime
        @p.source_id = s.id
        @p.image=entry.image if defined? entry.image
        s2 = entry.categories[0] if defined? entry.category
        cat1 = Category.find_by(name: s2) || Category.new
        #cat1.name="Без категории" if cat1.id==19
        #cat1.save
        if cat1.blank?
          c = Category.new
          c.name = entry.categories[0]
          c.name=="Без категории" if c.name==nil
          c.save
          cat1 = Category.last
        end
        @p.category_id = cat1.id
        if entry.summary.blank?
          entry.summary = ' '
        else
          @p.summary = entry.summary[0..400]
        
        end
        puts @p.title
        @p.save
        @p = Page.last
        ActsAsTaggableOn.delimiter = [' ', ',']
        @p.tag_list.add(@p.title, parse: true)
        puts @p.tag_list
        @p.save
      
      end
    end
  end
end

# ProjectCleanupWorker.new.perform(@project.id)  ## NOT BACKGROUND
#FetchNewsWorker.perform_async(20.minutes, sources)
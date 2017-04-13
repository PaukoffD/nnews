class FetchNewsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # Important!

  #$cnt=0
  def perform(sources,count)
    source = Source.all

    cnt=0
    source.rss.each do |s|
      url = s.ref
      #puts s.name, s.ref
      begin
        feed = Feedjira::Feed.fetch_and_parse url
      rescue Feedjira::FetchFailure => e
        Rails.logger.error e.message
        next
      rescue Feedjira::NoParserAvailable => e
        Rails.logger.error e.message
        next
      rescue StandardError=>e
        Rails.logger.error e.message
        next
      end
      feed.entries.each do |entry|
        @p = Page.create(title: entry.title,
                         published: entry.published.to_datetime,
                         ref: entry.url,
                         source_id: s.id,
                         summary: entry.summary)
        s2 = entry.categories[0] if defined? entry.categories
        cat1 = Category.find_by(name: s2)
        #cat1.name="Без категории" if cat1.name=="19"
        #cat1.save
        if cat1.blank?
          c = Category.new
          c.name = entry.categories[0]
          c.name = "Без категории" if c.name==nil
          c.save
          cat1 = Category.last
        end
        @p.category_id = cat1.id
        @p.image=entry.image if defined? entry.image
        begin
          Page.transaction do
            cnt=cnt+1
            @p.save!
          end
        rescue => e
          cnt=cnt-1
        end
        #   puts "колво в фид  " ,cnt
      end
      #puts @p.title
      @p.save
      @p = Page.last
      ActsAsTaggableOn.delimiter = [' ', ',']
      @p.tag_list.add(@p.title, parse: true)
      @p.save
    end
    $redis.set('cnt', cnt)
    #$cnt=cnt
  end
end


# ProjectCleanupWorker.new.perform(@project.id)  ## NOT BACKGROUND
#FetchNewsWorker.perform_async(20.minutes, sources)
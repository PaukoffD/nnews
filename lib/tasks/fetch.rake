require 'rubygems'
require 'telegram/bot'


task fetch: :environment do
 puts "RSS load" 
 source = Source.all
 token= '328736940:AAE9h5HdxT1897syuj5-xZTxOecG8mWYQ0s'
 Telegram::Bot::Client.run(token) do |bot|
 cnt=0
   source.rss.each do |s|
    url = s.ref
    puts s.name, s.ref
    begin
    feed = Feedjira::Feed.fetch_and_parse url
    
    
    rescue Feedjira::FetchFailure => e
       Rails.logger.error e.message
      next
     #end   
    rescue Feedjira::NoParserAvailable => e
       Rails.logger.error e.message
      next
     end   
    feed.entries.each do |entry|
       @p = Page.create(title: entry.title,
                            published: entry.published.to_datetime,
                            ref: entry.url,
                            source_id: s.id,
                            summary: entry.summary
                            )
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

    end  

  end  
  pages = Page.order('published DESC').limit(cnt)
    pages.each do |s|
      #puts s.title
      bot.api.send_message(chat_id: "@paukoffnews" , text: "#{s.title} #{s.ref}")
      #sleep 15
      #loa
    end
  end
end 
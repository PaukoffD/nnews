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
    
    
    rescue Faraday::Error::ConnectionFailed => e
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
       if @p.save
        bot.api.send_message(chat_id: 118319165, text: "#{@p.ref}")
        cnt=cnt+1
        #loa
       end 

    end  
  end  
  end
end
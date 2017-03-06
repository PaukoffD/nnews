require 'rubygems'
require 'telegram/bot'
require 'lingua/stemmer'
require 'matrix'
#require 'bugsnag'


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
    #   puts "колво в фид  " ,cnt
    end  

 #cnt +=cnt
 puts cnt
 @cnt=cnt
 ttags=[]
 tags=Tagexcept.all
 tags.each do |t|
   ttags<<t.name
 end
 pages = Page.order('created_at DESC').where(taggs: "").limit(@cnt)
 #binding.pry
 pages.each do |s|
   s1=Lingua.stemmer( s.title.gsub(/[\,\.\?\!\:\;\"\']/, "").downcase.split-ttags, :language => "ru" )
   s2=''
   for i in (0..s1.length-1) do
     break if i>2
     s2 << s1[i]+" "
   end
   if s.taggs.blank? #если колво меньше 3 исправить
     for i in (0..s1.length-1) do
       break if i>2
       s.taggs << s1[i]+" "
       #binding.pry
     end
     s.save
     #binding.pry
   end
 end
 end

 ttags=[]
 tags=Tagexcept.all
 tags.each do |t|
   ttags<<t.name
 end
 corpus=[]
 pages = Page.order('created_at DESC').limit(@cnt)
 # lo
 pages.each do |s|
   corpus=[]
   spl=s.taggs.split
   if spl[2].nil?
     mpages=Page.order('created_at ASC').where("taggs LIKE '%#{spl[0]}%' or taggs LIKE '%#{spl[1]}%'").order('created_at DESC').limit(99)
   elsif  spl[1].nil?
     mpages=Page.order('created_at ASC').where("taggs LIKE '%#{spl[0]}%'").order('created_at DESC').limit(99)
   elsif  spl[0].nil?
     next
   else
     mpages=Page.order('created_at ASC').where("taggs LIKE '%#{spl[0]}%' or taggs LIKE '%#{spl[1]}%' or taggs LIKE '%#{spl[2]}%'").order('created_at DESC').limit(99)
   end
   #binding.pry
   next  if mpages.length==1
   #binding.pry
   s1=Lingua.stemmer( s.title.gsub(/[\,\.\?\!\:\;\"\-\']/, "").downcase.split-ttags, :language => "ru" )
   #lo
   s2=''
   for i in (0..s1.length-1) do
     #  break if i>2
     s2 << s1[i]+" "
   end
  
   if s.taggs.blank? #если колво меньше 3 исправить
    
     for i in (0..s1.length-1) do
       break if i>2
       s.taggs << s1[i]+" "
     end
    
    
     s.save
   end
  
   #doc = TfIdfSimilarity::Document.new(s2)
   #corpus << doc
   #lo
   mpages.each do |ss|
     #ss1=Lingua.stemmer( s.title.gsub(/[\,\.\?\!\:\;\"\-\']/, "").downcase.split-ttags, :language => "ru" )
     #ss2=''
     #for i in (0..s1.length-1) do
     #  break if i>2
     #  s2 << s1[i]+" "
     #end
     doc = TfIdfSimilarity::Document.new(ss.taggs)
     corpus << doc
     #binding.pry
   end
  
  
   model = TfIdfSimilarity::TfIdfModel.new(corpus)
   matrix = model.similarity_matrix
  
   #binding.pry
   #puts matrix.count

   for i in 0..corpus.length-1 do
     for j in 0..corpus.length-1 do
       if matrix[i,j]>0.65 && matrix[i,j]<0.998 && i<j
         puts matrix[i,j]
         puts i
         puts j
         puts mpages[i].title
         puts mpages[j].title
         q=Pagematch.find_by(page_id: mpages[i].id)
         #lo
         if q.nil?
           pm=Pagematch.new
           pm.page_id=mpages[i].id
           pm.match_id=mpages[j].id
           pm.koef=matrix[i,j]
           sss1 = Page.find(mpages[i].id)
           sss2 = Page.find(mpages[j].id)
           sss1.flag_match=true
           sss2.flag_match=true
           if sss1.cnt_match.nil?
             sss1.cnt_match=1
           end
           sss1.dupl=false
           sss2.dupl=true
           #lo
           #if sss1.dupl && !sss2.dupl
           #  sss1.dupl=false
           #else
           #  sss1.dupl=true
           #end
           begin
             Page.transaction do
               sss1.save!
               sss2.save!
               pm.save!
             end
           rescue => e
             next
           end
         else
           #ind=Pagematch.where(page_id: q.page_id).pluck(:match_id)
           sss1 = Page.find(q.page_id)
           #lo
           sss2 = Page.find(mpages[j].id)
           sss1.flag_match=true
           sss2.flag_match=true
           sss1.cnt_match +=1
           puts sss1.cnt_match, "increase 1"
           sss1.dupl=false
           sss2.dupl=true
           #lo
           #if sss1.dupl && !sss2.dupl
           #  sss1.dupl=false
           #else
           #  sss1.dupl=true
           #end
           begin
             Page.transaction do
               sss1.save!
               sss2.save!
               q.save!
             end
           rescue => e
             next
           end
         end
       end
     end
   end
 end
puts cnt
  pages = Page.order('published DESC').limit(@cnt)
    pages.nodup.each do |s|
      puts @cnt
      puts s.title
      bot.api.send_message(chat_id: "@paukoffnews" , text: "#{s.published.to_time().in_time_zone("Moscow").strftime("%R")} #{s.title} #{s.ref}")
      #sleep 15
      #loa
    end
 end


end 
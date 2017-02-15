require 'will_paginate/array'

class Dop


  def proba1
    source = Source.all
    token= '328736940:AAE9h5HdxT1897syuj5-xZTxOecG8mWYQ0s'
    Telegram::Bot::Client.run(token) do |bot|
      cnt=0
      source.rss.each do |s|
        url = s.ref

        #   @newest_entry = Page.order(published: :desc).where(source_id: s.id).first
        begin
          feed = Feedjira::Feed.fetch_and_parse url
          rescue Feedjira::FetchFailure => e
          Rails.logger.error e.message
          next
          rescue Feedjira::NoParserAvailable => e
          Rails.logger.error e.message
         next
        end

      feed.entries.each do |entry|

       # next unless !@newest_entry || entry.published > @newest_entry.published
       #loa
       @p = Page.new(title: entry.title,
                              published: entry.published,
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
             c.name = s2
             c.name = "Без категории" if c.name==nil
             c.save
             cat1 = Category.last
           end
        @p.category_id = cat1.id
       @p.image=entry.image if defined? entry.image
         ActsAsTaggableOn.delimiter = [' ', ',']
        #loa
        @p.tag_list.add(@p.title, parse: true)

        begin
          Page.transaction do
            cnt=cnt+1
            @p.save!
          end
         rescue => e
           cnt=cnt-1

        end



      end
    puts cnt
   end
  puts cnt

  pages = Page.order('created_at DESC').limit(cnt)
    pages.each do |s|
      #puts s.title
      bot.api.send_message(chat_id: 118319165 , text: "#{s.title} #{s.ref}")

    end
   end
  end

  def load_html
    page = Nokogiri::HTML(open('#{s.common1}'))
    link1=page.xpath("#{s.common1}")
    link1.children.each do |link|
      pg=Page.new
      pg.title='#{s.title}'.to_s
      pg.ref='#{s.ref}'.to_s
      pg.published='#{s.published}'.to_s
      pg.save
    end
  end

   #begin
   #page = Nokogiri::HTML(open("http://utro.ru/news/"))
   #link1=page.xpath('/html/body/div[4]/div[4]/div/div[3]/div')
   #link1.children.each do |link|
   #puts link.at_css(" a").text
   # puts link
   #pg=Page.new
   #pg.title=link.children.at_css("a").text
   #pg.ref=link.children.at_css("a")['href']
   #pg.time= link.children.at_css(" div div div").text
   #pg.save
   #end
  # Категории
          # page.css(".ms_child").each do |link|
          #puts link.text
          #st=link.text
          # c=Category.new
        #      st = link.at_css("tr[4] td[1] div a").text
           # puts link.at_css("tr[4] td[1] div a").text
         # c.name=st
         #//*[@id="new_content"]/div[3]/div/div/div/div/table/tbody/tr[3]/td[1]/div/a
        # puts c.name
        #c.save
        #puts //*[@id="new_content"]/div[3]/div/div/div/div/table/tbody/tr[1]/td[1]/div/a
        #end
  #puts page.at_css(".ob_rubrika").text

    #@topics = Topic.order(:created_at).reorder('id DESC').all.page(params[:page])
    #topic=Topic.order(:created_at).reorder('id DESC').last
  #@forum = Forum.find(topic.forum_id)
   #puts page.css("title")[0].name # => title
   #puts page.css("title")[0].text
  # page.css(".ob").each do |link|
  #  @notice=Tmpnotice.new
  #  @notice.notice=link.at_css(".ob_title").text
 # s=link.at_css(".photo_preview")
  #if !s.name="td"
 #  @notice.ref_img=link.at_css(".photo_preview img")['src']
 # end
 # @notice.ref_page=link.at_css(".ob_descr td a")['href']
 # @notice.name=link.at_css(".author").text

  #@notice.text=link.at_css("p[3]").text

 # @notice.save
 # end

 #begin rueconomics
   #page = Nokogiri::HTML(open("http://rueconomics.ru"))
   #page.xpath('//*[contains(@class,"news")]').each do |link|
   #link1.children.each do |link|
   #puts link.at_css(" a").text
   #next if link.values[0].match('city')
   #next if link.values[0].match('choose')
   #next if link.values[0].match('post')
   #next if link.values[0].match('category')
   #next if link.values[0].match('main')
   #next if link.values[0].match('border')
    #puts link
   #loa
   #pg=Page.new
   #pg.title=link.at_css("a").values[1]
   #puts pg
   #pg.ref=link.at_css("a").values[0]
   #puts pg
   #d=Date.today
   #pg.time= link.at_css("div div").text.to_datetime
   #puts pg
   #pg.save
  #end
  # end rueconomics
#end

  def fetch_news
    @pages = $redis.get('pages')

    if @pages.nil?
      @pages = Page.order('published DESC').page(params[:page]).to_json
      $redis.set('pages', @pages)
      # Expire the cache, reorder('time DESC').page(params[:page]).very 5 hours
      $redis.expire('pages', 17.minutes.to_i)
    end
    @pages = JSON.load @pages


    @sources = $redis.get('sourses')
    if @sources.nil?
      @sources = Source.all.to_json
      $redis.set('sources', @sources)
      # Expire the cache, reorder('time DESC').page(params[:page]).very 5 hours
      $redis.expire('sources', 5.hours.to_i)
    end

    @sources = JSON.load @sources

    @rel = $redis.hget(@rel,'rel')

    if @rel.nil?
        @rel=Hash.new
        i=0
        @sources.each do |c|
         @rel[i]=c['id']
         $redis.hset( @rel ,'rel', c['id'])
         i+=1
        end

    @rel=@rel.invert

      # Expire the cache, reorder('time DESC').page(params[:page]).very 5 hours
      $redis.expire('rel', 5.hours.to_i)
    end
    #@rel = JSON.load @rel

  end

    def load_rss
     source = Source.all
     token= '328736940:AAE9h5HdxT1897syuj5-xZTxOecG8mWYQ0s'
     Telegram::Bot::Client.run(token) do |bot|
     cnt=0
     source.rss.each do |s|
       url = s.ref

      #   @newest_entry = Page.order(published: :desc).where(source_id: s.id).first
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

         # next unless !@newest_entry || entry.published > @newest_entry.published
         #loa
         @p = Page.new(title: entry.title,
                                published: entry.published,
                                ref: entry.url,
                                source_id: s.id,
                                summary: entry.summary
                                )
         #@p.title = entry.title
          #@p.ref = entry.url
          #@p.time = entry.published.to_datetime
          #@p.source_id = s.id
          #@p.image=entry.image if defined? entry.image
         # s2 = entry.categories[0] if defined? entry.category
          #cat1 = Category.find_by(name: s2) || Category.new
          #cat1.name="Без категории" if cat1.id==19
          #cat1.save
          #if cat1.blank?
          #   c = Category.new
         #    c.name = entry.categories[0]
          #   c.name=="Без категории" if c.name==nil
         #    c.save
         #    cat1 = Category.last
        #   end
        #  @p.category_id = cat1.id
       #   if entry.summary.blank?
        #    entry.summary = ' '
       #    else
       #     @p.summary = entry.summary[0..400]
       #
      #     end
          s2 = entry.categories[0] if defined? entry.categories
          cat1 = Category.find_by(name: s2)
          #cat1.name="Без категории" if cat1.name=="19"
          #cat1.save

            if cat1.blank?
               c = Category.new
               c.name = s2
               c.name = "Без категории" if c.name==nil
               c.save
               cat1 = Category.last
             end
          @p.category_id = cat1.id
         @p.image=entry.image if defined? entry.image
           ActsAsTaggableOn.delimiter = [' ', ',']
          #loa
          @p.tag_list.add(@p.title, parse: true)

          begin
            Page.transaction do
              cnt=cnt+1
              @p.save!
            end
           rescue => e
             cnt=cnt-1
           #lo
          end



        end
      puts cnt
     end
    puts cnt
    @cnt=cnt
    ttaggs

    ttags=[]
    tags=Tagexcept.all
    tags.each do |t|
      ttags<<t.name
    end
    corpus=[]
    pages = Page.order('created_at DESC').limit(cnt)
       # lo
    pages.each do |s|
      corpus=[]
      spl=s.taggs.split
      if spl[2].nil?
        mpages=Page.order('created_at ASC').where("taggs LIKE '%#{spl[0]}%' or taggs LIKE '%#{spl[1]}%'")
      elsif  spl[1].nil?
        mpages=Page.order('created_at ASC').where("taggs LIKE '%#{spl[0]}%'")
      elsif  spl[0].nil?
        next
      else
        mpages=Page.order('created_at ASC').where("taggs LIKE '%#{spl[0]}%' or taggs LIKE '%#{spl[1]}%' or taggs LIKE '%#{spl[2]}%'")
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
      puts matrix.count

    for i in 0..corpus.length-1 do
        for j in 0..corpus.length-1 do
          if matrix[i,j]>0.5 && matrix[i,j]<0.998 && i<j
            puts matrix[i,j]
            puts i
            puts j
            puts mpages[i].title
            puts mpages[j].title
            q=Pagematch.find_by(page_id: mpages[i].title)
            if q.nil?
              pm=Pagematch.new
              pm.page_id=mpages[i].id
              pm.match_id=mpages[j].id
              pm.koef=matrix[i,j]
              sss1 = Page.find(mpages[i].id)
              sss2=Page.find(mpages[j].id)
              sss1.flag_match=true
              if sss1.cnt_match.nil?
                sss1.cnt_match=1
              else
                sss1.cnt_match+=1
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
               #lo

              end
            #else





            #end
          end
        end

    #pages = Page.order('created_at DESC').limit(cnt)
    #  pages.each do |s|
        #puts s.title
    #    bot.api.send_message(chat_id: 118319165 , text: "#{s.title} #{s.ref}")
        end
    end
    end
     end


  end

  private
  def ttaggs
    ttags=[]
    tags=Tagexcept.all
    tags.each do |t|
      ttags<<t.name
    end
    pages = Page.order('created_at DESC').where(taggs: "").limit(@cnt)
    #binding.pry
    pages.each do |s|
      s1=Lingua.stemmer( s.title.gsub(/[\,\.\?\!\:\;\"]/, "").downcase.split-ttags, :language => "ru" )
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

end

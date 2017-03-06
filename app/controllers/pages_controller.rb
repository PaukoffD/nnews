# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  title       :string
#  ref         :string
#  time        :time
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  source_id   :integer          default(0)
#  summary     :string
#  category_id :integer          default(0)
#  tagtitle    :string
#

class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]
  require 'open-uri'
  require 'rubygems'
  require 'text'
  require 'time'
  require 'csv'
  require 'telegram/bot'
  require 'matrix'
  require 'dop'
  require 'set'
  require 'uri'
  require 'nokogiri'
  require 'lingua/stemmer'

  include PagesHelper
  TWODAYS = 2*24*60*60

    def diff
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
            mpages=Page.where("taggs LIKE '%#{spl[0]}%' or taggs LIKE '%#{spl[1]}%'").where(created_at:(Time.now - 2.day)..Time.now).order('created_at DESC').limit(99)
            #lo
          elsif  spl[1].nil?
            mpages=Page.where("taggs LIKE '%#{spl[0]}%'").where(created_at:(Time.now - 2.day)..Time.now).order('created_at DESC').limit(99)
          elsif  spl[0].nil?
            next
          else
            mpages=Page.where("taggs LIKE '%#{spl[0]}%' or taggs LIKE '%#{spl[1]}%' or taggs LIKE '%#{spl[2]}%'").where(created_at:(Time.now - 2.day)..Time.now).order('created_at DESC').limit(99)
            #lo
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
        #end
        puts cnt
        #pages = Page.order('published DESC').limit(@cnt)
        #pages.nodup.each do |s|
        #  puts @cnt
        #  puts s.title
        #  bot.api.send_message(chat_id: "@paukoffnews" , text: "#{s.published.to_time().in_time_zone("Moscow").strftime("%R")} #{s.title} #{s.ref}")
          #sleep 15
          #loa
        #end
      end



    end

  def load
    t1=Dop.new
    t1.load_rss
  end

  def proba
   proba1
  end

  def parser
   crawl_site('https://www.bfm.ru/news?type=news') do |page,uri|
  # page here is a Nokogiri HTML document
  # uri is a URI instance with the address of the page
   puts uri
  end
end

def tgram
  token= '328736940:AAE9h5HdxT1897syuj5-xZTxOecG8mWYQ0s'
Telegram::Bot::Client.run(token) do |bot|
  pages = Page.order('created_at DESC').limit(10)
    pages.each do |s|
      puts s.title
      bot.api.send_message(chat_id: 118319165, text: "#{s.ref}")
      #sleep 15
      #loa
    end
  end
end

  def analyze

  end

 def tmp
    #source = Source.all
   # source.each do |s|

      #  ss=Sourcehtml.first
       page = Nokogiri::HTML(open("http://rueconomics.ru"))

       link1=page.xpath('//*[contains(@class,"left_news_post")]')

       link1.each do |link|


        #loa
        title=link.at_css("h3 a").text if defined? link.at_css("h3 a").text1

        next if title.nil?
        pg=Page.new
        pg.title=title
        pg.ref=link.at_css("h3 a")['href'] if defined? link.at_css("h3 a")['href']
        pg.time=link.at_css("span").text.delete("Сегодня ") if defined? link.at_css("span").text.delete("Сегодня ")
        pg.image=link.at_css('div a img')['src'] if defined? link.at_css('div a img')['src']
        pg.summary=link.children[7].text if defined? link.children[7].text
        # loa
       # pg.source_id=ss.source_id
        pg.save

       end
      end





  def search_tags1
    render :search_tags
     @tag = params[:tag]
     if @tag.blank?
      # loa
     # redirect_to :root, notice: "Заполни"
     else
       redirect_to :index, notice: "ищем!"
     end
  end

  def search_tags
  end

  def rss
    @source = Source.all
    analyzerss
    #@feed=FeedPresenter.new(@source)
    #@feed.caption
    #lo
  end

  def html
      @sources = Source.where(html: true)

  end



  def index

  #@translator = Yandex::Translator.new('trnsl.1.1.20160606T092333Z.48fc2e0ec17ebab3.69be4ac22af90838d34cb67de1e6dc0f2fe261c5')

    if params[:category]
      @pages = Page.where('category_id' => params['category']).order('published DESC').page(params[:page])
    elsif params[:tag]
      @pages = Page.tagged_with(params[:tag]).order('published DESC').page(params[:page])
    elsif params[:id]
      @pages = Page.where('source_id' => params['id']).order('published DESC').page(params[:page])
    elsif params[:data]
     @pages = Page.where(published: (params['data'].to_time.beginning_of_day..params['data'].to_time.end_of_day)).order('published DESC').page(params[:page])
    #loa
    elsif params[:datetimepicker12]
     @pages = Page.where(published: (params['datetimepicker12'].to_time.beginning_of_day..params['datetimepicker12'].to_time.end_of_day)).order('published DESC').page(params[:page])
    # loa
    elsif params[:tags]
     @pages = Page.tagged_with(params[:tags]['tag']).order('published DESC').page(params[:page])
    elsif params[:q]
     @search = Page.search(params[:q])
    @pages = @search.result.order('published DESC').page(params[:page])
    elsif params[:format]
      @pages = Page.where('source_id' => params['format']).order('published DESC').page(params[:page])
    else
      @pages = Page.nodup.order('published DESC').page(params[:page])
    end

    FetchNewsWorker.perform_async(sources,5.minutes)
    #loa
   @categories = Category.all.order('count DESC').limit(50)
   @search = Page.search(params[:q])
   @sources = Source.all
    # @pages = @search.result.order('time DESC').page(params[:page])
  end

  def redis
   @source = Source.all
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

  def tag_cloud
       # @tags = Tags.all.order('count DESC')
  end


  # GET /pages/1
  # GET /pages/1.json
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
  end


  def edit
  end





  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to @page, notice: 'Page was successfully updated.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url, notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def crawl_site( starting_at, &each_page )
  files = %w[png jpeg jpg gif svg txt js css zip gz]
  starting_uri = URI.parse(starting_at)
  seen_pages = Set.new                      # Keep track of what we've seen

  crawl_page = ->(page_uri) do              # A re-usable mini-function
    unless seen_pages.include?(page_uri)
      seen_pages << page_uri                # Record that we've seen this
      begin
        doc = Nokogiri.HTML(open(page_uri)) # Get the page
        each_page.call(doc,page_uri)        # Yield page and URI to the block

        # Find all the links on the page
        hrefs = doc.css('li').css('.title-link').map{ |a| a['href'] if a['href'].to_s.match("news") }.compact
        #hrefs.map{|a| a.to_s.match("news")}
        #binding.pry
        # Make these URIs, throwing out problem ones like mailto:
        @uris = hrefs.map{ |href| URI.join( page_uri, href ) rescue nil }.compact
        lo
        #binding.pry
        #puts uris
        #@uris=uris
        #puts @uris
        # Pare it down to only those pages that are on the same site
        #uris.select!{ |uri| uri.host == starting_uri.host }

        # Throw out links to files (this could be more efficient with regex)
        #uris.reject!{ |uri| files.any?{ |ext| uri.path.end_with?(".#{ext}") } }

        # Remove #foo fragments so that sub-page links aren't differentiated
        #uris.each{ |uri| uri.fragment = nil }

        # Recursively crawl the child URIs
        #uris.each{ |uri| crawl_page.call(uri) }

      rescue OpenURI::HTTPError # Guard against 404s
        warn "Skipping invalid link #{page_uri}"
      end
    end
  end

  crawl_page.call( starting_uri )   # Kick it all off!
  end

  def addwindow
    @page=Page.find(params[:format])
    ind=Pagematch.where(page_id: @page.id).pluck(:match_id)
    @mpages=Page.where(id: ind)
    #lo
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def trunc(text)
    text.gsub(/\<[\/]*a[^\>]*\>/, "")
  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def page_params
    params.require(:page).permit!
    params.require(:page).permit(:title, :tag_list)
  end
end

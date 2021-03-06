require 'lingua/stemmer'
require 'matrix'

class PagematchWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # Important!


  def perform(count)
   # puts $cnt
    @cnt= $redis.get('cnt')
    puts @cnt
    ttags=[]
    tags=Tagexcept.all
    tags.each do |t|
      ttags<<t.name
    end
    pages = Page.order('created_at DESC').where(taggs: "").limit(@cnt)
    #binding.pry
    pages.each do |s|
      s1=Lingua.stemmer( s.title.gsub(/[\,\.\?\!\:\;\"\'\-\`]/, "").downcase.split-ttags, :language => "ru" )
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
  end

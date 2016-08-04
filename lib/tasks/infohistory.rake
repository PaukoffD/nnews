#пробегается по базе на 250 дней и создает записи
task infohistory: :environment do
    
  
   @source = Source.all
   @source.each do |a|
    
    for i in 0..250 do
    info=Info.new
    count=Page.where(source_id: a.id, time: ((Date.today-i).to_time.beginning_of_day..(Date.today-i).to_time.end_of_day)).count
    @tags = ActsAsTaggableOn::Tag.all.count
    @pg=Page.where(source_id: a.id, time: ((Date.today-i).to_time.beginning_of_day..(Date.today-i).to_time.end_of_day)).pluck(:id)
    tagging_count=ActsAsTaggableOn::Tagging.where(taggable_id: @pg).count 
    info.tagging=tagging_count
    @tg=ActsAsTaggableOn::Tagging.select('distinct tag_id').where(taggable_id: @pg).count
    #tg1=@tg.distinct.count
    info.tag_count=@tg
    puts count
    info.source_id=a.id
    info.page_count=count
    info.data=Date.today-i
    info.save
   end
   end 
  end
#считает колво по source...раз в час 
task infohour: :environment do
    
   
   @source = Source.all
   @source.each do |a|
    info=Info.find_by_source_id(a.id) || Info.new
    count=Page.where(source_id: a.id).count
    @pg=Page.where(source_id: a.id).pluck(:id)
    tagging_count=ActsAsTaggableOn::Tagging.where(taggable_id: @pg).count 
    @tg=ActsAsTaggableOn::Tagging.select('distinct tag_id').where(taggable_id: @pg).count
    info.tag_count=@tg
    info.tagging=tagging_count 
    info.source_id=a.id
    info.page_count=count
    info.save
   end 
end
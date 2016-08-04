#Создает первую запись и считает ...раз в день
task infoday: :environment do
	  
   @pages = Page.all.count
   @tags = ActsAsTaggableOn::Tag.all.count
   @taggings = ActsAsTaggableOn::Tagging.all.count
   @source = Source.all.count
   info=Info.first || Info.new
   info.page_count=@pages
   info.tag_count=@tags
   info.tagging=@taggings 
   info.size=@source
   info.save
end

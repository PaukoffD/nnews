task info: :environment do
   @s=Source.all
   @s.each do |source|
    pages_count = source.pages.all.count
    info=Info.find(source_id: source.id) || Info.new
    info.size=pages_count
    info.save
   end 
end

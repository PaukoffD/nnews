task category: :environment do
   @cats=Category.all
   @cats.each do |cat|
      cat.count=Page.where(category_id: cat.id).count
      cat.save
      puts cat.name
   end
 
end

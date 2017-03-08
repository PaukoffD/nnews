class CategoryWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # Important!


  def perform(count)
    @cats=Category.all
    @cats.each do |cat|
      cat.count=Page.where(category_id: cat.id).count
      cat.save
      puts cat.name,cat.count
    end
  end
end
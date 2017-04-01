require 'lingua/stemmer'
class TagsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # Important!


  def perform(count)
    # ActsAsTaggableOn.delimiter = [' ', ',']
    puts "Work with tags"

    @pages = Page.joins('LEFT OUTER JOIN "taggings" ON "taggings"."taggable_id" = "pages"."id"').where(taggings: {taggable_id: nil}).limit(1000)
    ActsAsTaggableOn.delimiter = [' ']
    puts @pages.count
    @pages.each do |p|
      p.tag_list.add(p.title, parse: true)
      p.save
    end
    tgs = Tagexcept.all
    tgsovlp = Tagoverlap.all

    tgs.each do |tt|
      result = ActsAsTaggableOn::Tag.where(name: tt.name)
      ActsAsTaggableOn::Tagging.where(tag_id: result).delete_all
      # puts result "deleted"
      ActsAsTaggableOn::Tag.where(name: tt.name).delete_all
    end
    tgsovlp.each do |pt1|
      result = ActsAsTaggableOn::Tag.where(name: pt1.name)
      result1 = ActsAsTaggableOn::Tag.where(name: pt1.nametarget)
      # res=result.tagging_count+result1.tagging_count

      if !result.blank? && !result1.blank?
        res = result[0]['taggings_count'] + result1[0]['taggings_count']
        result[0]['taggings_count'] = res
        ActsAsTaggableOn::Tagging.where(tag_id: result).update_all(tag_id: result1)

        ActsAsTaggableOn::Tag.where(name: pt1.nametarget).update_all(taggings_count: res)
        ActsAsTaggableOn::Tag.where(name: pt1.name).delete_all

      else
        unless result.blank?
          ActsAsTaggableOn::Tagging.where(tag_id: result).update_all(tag_id: result[0]['id'])
          ActsAsTaggableOn::Tag.where(name: pt1.name).update_all(name: pt1.nametarget)
        end
      end
    end


    ttags=[]
    tags=Tagexcept.all
    tags.each do |t|
      ttags<<t.name
    end
    pages = Page.order('created_at DESC').where(taggs: "").limit(1000)
    pages.each do |s|
      s1=Lingua.stemmer( s.title.gsub(/[\,\.\?\!\:\;\"\'\-\`]/, "").downcase.split-ttags, :language => "ru" )

      if s.taggs.blank?
        for i in (0..s1.length-1) do
          s.taggs << s1[i]+" "
        end
        s.save
      end
    end
  end
end
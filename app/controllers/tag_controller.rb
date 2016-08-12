class TagController < ApplicationController

  def tagexceptexport
    @tags = Tagexcept.all
    f=File.new('tagexcepts.txt', 'r+') 
    @tags.each do |tt|
      f << [tt.id.to_s,tt.name].join(';') <<"\n"
     end
  end

  def tagexceptimport
   csv = CSV.foreach('tagexcepts.txt', :headers => false)
   csv.each do |row|
    a=row.to_s.split(";")
    s1=a[0][2,a[0].length-2]
    tagexcept=Tagexcept.find_by_id(s1)|| Tagexcept.new
    tagexcept.name=a[1][0,a[1].length-2]
    tagexcept.save
   end
  end

  def tagoverlapexport
    @tags = Tagoverlap.all
    f=File.new('tagoverlaps.txt', 'r+') 
    @tags.each do |tt|
      f << [tt.id.to_s,tt.name].join(';') <<"\n"
    end
  end

  def tagoverlapimport
   csv = CSV.foreach('tagoverlaps.txt', :headers => false)
   csv.each do |row|
    a=row.to_s.split(";")
    s1=a[0][2,a[0].length-2]
    tagoverlap=Tagoverlap.find_by_id(s1)|| Tagoverlap.new
    tagoverlap.name=a[1][0,a[1].length-2]
    tagoverlap.save
   end
  end

	def tagexport
    @tags = ActsAsTaggableOn::Tag.all
    f=File.new('tags.txt', 'r+') 
    @tags.each do |tt|
      f << [tt.id.to_s,tt.name].join(';') <<"\n"
    end
  end

  def tagimport #доделать
   csv = CSV.foreach('tags.txt', :headers => false)
   csv.each do |row|
   a=row.to_s.split(";")
   a.each do |b|
    tag = Tagexcept.new
    if b.match("\\[")
       tag.name=b[2,b.length-2]
     elsif  !b.match('\\]')
       tag.name=b
     end
    tag.save
   end
   end
  end

def atags #add tags
   @pages = Page.joins('LEFT OUTER JOIN "taggings" ON "taggings"."taggable_id" = "pages"."id"').where(taggings: {taggable_id: nil})
   ActsAsTaggableOn.delimiter = [' ']
   @pages.each do |p|   
     p.tag_list.add(p.title, parse: true)
     p.save
    end  
  end

   def rtags # remove tags
   tgs = Tagexcept.all
   tgsovlp = Tagoverlap.all
   tgs.each do |pt|

      result = ActsAsTaggableOn::Tag.where(name: pt.name)
    ActsAsTaggableOn::Tagging.where(tag_id: result).delete_all
     ActsAsTaggableOn::Tag.where(name: pt.name).delete_all
   end
    tgsovlp.each do |pt1|
        result = ActsAsTaggableOn::Tag.where(name: pt1.name)
    result1 = ActsAsTaggableOn::Tag.where(name: pt1.nametarget)
    # res=result.tagging_count+result1.tagging_count
    
     if !result.blank? && !result1.blank?
      res = result[0]['taggings_count'] + result1[0]['taggings_count']
      result[0]['taggings_count'] = res
       ActsAsTaggableOn::Tagging.where(tag_id: result).update_all(tag_id: result[0]['id'])
     
      ActsAsTaggableOn::Tag.where(name: pt1.nametarget).update_all(taggings_count: res)
      ActsAsTaggableOn::Tag.where(name: pt1.name).delete_all
    
    else
    unless result.blank?
     ActsAsTaggableOn::Tagging.where(tag_id: result).update_all(tag_id: result[0]['id'])
     ActsAsTaggableOn::Tag.where(name: pt1.name).update_all(name: pt1.nametarget)
    end
    end
  end
    @cats=Category.all
    @cats.each do |cat|
      cat.count=Page.where(category_id: cat.id).count
      cat.save
   end
  
  end

end

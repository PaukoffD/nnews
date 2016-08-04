task html: :environment do
 source = Source.all
   shtml= Sourcehtml.all
    source.html.each do |s|
      shtml.each do |ss|
       #ss=Sourcehtml.first
       page = Nokogiri::HTML(open("#{ss.common1}"))
       link1=page.xpath("#{ss.common2}")
       link1.each do |link|
        begin 
        title=eval("#{ss.title}") if defined? eval("#{ss.title}")
        next if title.nil?
        pg=Page.new
        pg.title=title
        ref=eval("#{ss.ref}")
        pg.ref=ss.url+ref
        tt=eval("#{ss.time}")
        pg.time=tt.to_datetime
        pg.source_id=ss.source_id
        image=eval("#{ss.image}") if defined? eval("#{ss.image}")
        pg.image=ss.url.to_s+image.to_s unless image.nil?
        pg.summary=eval("#{ss.summary}") if defined? eval("#{ss.summary}")
        pg.save
        rescue
          next
          
        end  
      end 
    end
   end  
end
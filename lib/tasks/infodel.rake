task infodel: :environment do
   @info=Info.first
   Info.delete_all

end

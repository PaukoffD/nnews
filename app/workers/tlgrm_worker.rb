require 'telegram/bot'

class TlgrmWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # Important!


  def perform(count)
    token= '328736940:AAE9h5HdxT1897syuj5-xZTxOecG8mWYQ0s'
    cnt = $redis.get('cnt')
    Telegram::Bot::Client.run(token) do |bot|
      pages = Page.order('published DESC').limit(cnt).order('published ASC')
      pages.nodup.each do |s|
        bot.api.send_message(chat_id: "@paukoffnews" , text: "#{s.published.to_time().in_time_zone("Moscow").strftime("%R")} #{s.title} #{s.ref}")
      end
    end
  end

end
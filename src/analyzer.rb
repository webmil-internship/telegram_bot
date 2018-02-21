class Analyzer
    MSCV_URL = 'https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/analyze'
  attr_accessor :bot, :token, :mscv_key, :message
  def initialize(bot, user_id, file_id, message)
    @token = ENV['token']
    @mscv_key = ENV['mscv_key']
    @file_id = file_id
    @bot = bot
    @message = message
    @user = message.from
    end

  def result
    tags = analyze
    save_ratings(tags)
  end

  def analyze
        file_url = TelegramImagePath.call(@file_id)
        uri = URI(MSCV_URL)
        uri.query = URI.encode_www_form({
                                            'visualFeatures' => 'tags',
                                            'language' => 'en'
                                        })
        request = Net::HTTP::Post.new(uri.request_uri)
        request['Content-Type'] = 'application/json'
        request['Ocp-Apim-Subscription-Key'] = @mscv_key
        request.body = {url: file_url}.to_json
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(request)
        end
        tags = JSON.parse(response.body)["tags"]
   end

   def save_ratings(tags)
     current_task = Task.where(date: Date.today).first.theme
     tag_right = true
     tags.each do |tag|
       if current_task == tag['name']
         Rating.create(user_id: @user.id, date: Date.today, theme: current_task,
                     confidence: tag['confidence'].round(4))
         return
       end
     end
     bot.api.send_message(
         chat_id: message.chat.id,
         text: 'But your photo has a wrong content. Send it again, please.')
   end
end
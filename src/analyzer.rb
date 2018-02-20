class Analyzer
    MSCV_URL = 'https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/analyze'
  attr_accessor :token, :mscv_key
  def initialize(user_id, file_id)
    @token = ENV['token']
    @mscv_key = ENV['mscv_key']
    @file_id = file_id
    @user_id = user_id
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
#заповнюємо таблицю рейтингів
        current_task = Task.where(date: Date.today).first.theme
        success_result = tags.detect { |tag| current_task == tag['name']}
        return unless success_result
        Rating.create(user_id:  @user_id, date: Date.today, theme: current_task,
                      confidence: success_result['confidence'].round(4))
  end
end
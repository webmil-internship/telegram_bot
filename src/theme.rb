class Theme
  THEMES = ['ball', 'house', 'car', 'flower', 'fish']
  def send_task
    if Task.find(date: Date.today).nil?
      Task.create(date: Date.today, theme: THEMES.sample)
    else Telegram::Bot::Client.run(ENV['token']) do |bot|
      User.where(is_active: true).each do |user|
        theme_today = Task.find(date: Date.today).theme
        task_today = "Hi, #{user.first_name}! Let's play a game. Send me a photo of #{theme_today}, please."
        bot.api.send_message(chat_id: user.user_id, text: task_today)
        end
      end
    end
  end
end
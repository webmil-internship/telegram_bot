class Talking
  RULES = 'The instruction of the game is very simple. Every day I give you ' +
      'a task: you should make a photo on a set theme and send me it from ' +
      '09:00 till 21:00 UTC+2. But remember you can send only one photo. After ' +
      'that you can see your daily rating. Good luck!!!'
  HELP = "/start - start the game
         /rules - show the instruction
         /help - show help
         /task - show task
         /ratings - show ratings
         /stop - stop the game"

  attr_accessor :bot, :message
  def initialize(bot, message)
    @bot = bot
    @message = message
    @user = message.from
  end

  def new_user
    user = User.new(user_id: @user.id, first_name: @user.first_name, last_name: @user.last_name, is_active: true)
    user.save
    bot.api.send_message(
        chat_id: message.chat.id,
        text: "Hi, #{@user.first_name}! Let's play a game. Read the /rules.")
  end

  def hi_user
    user = User.first(user_id: @user.id, is_active: false)
      if user
        user.update(is_active: true)
        bot.api.send_message(
            chat_id: message.chat.id,
            text: "Hi, #{@user.first_name}! Welcome again!")
      elsif User.first(user_id: @user.id, is_active: true)
        bot.api.send_message(
            chat_id: message.chat.id,
            text: "Hi, #{@user.first_name}!")
      else
        new_user
      end

    end

  def help
    bot.api.send_message(
      chat_id: message.chat.id,
      text: HELP
    )
  end

  def rules
    bot.api.send_message(
      chat_id: message.chat.id,
      text: RULES
    )
  end

  def task
    if Task.find(date: Date.today).nil?
      bot.api.send_message(
          chat_id: message.chat.id,
          text: "Hi, #{@user.first_name}! Task is not ready yet."
      )
    else
      task_today = Task.find(date: Date.today).theme
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Send me a photo of #{task_today}, please."
      )
    end
  end

  def ratings_today
    if Rating.find(date: Date.today).nil?
      bot.api.send_message(
          chat_id: message.chat.id,
          text: "Hi, #{@user.first_name}! Rating is not ready yet."
      )
    else
      rating = Rating.join(:users, user_id: :user_id).where(date: Date.today).reverse_order(:confidence)
      i=1
      text_rates = ''
      rating.each do |row|
        text_rates += "#{i}. #{row[:first_name]} - #{row[:confidence]}\n"
        i+=1
    end
      bot.api.send_message(chat_id: message.chat.id,
                         text: text_rates
      )
    end
  end

  def all_ratings
    bot.api.send_message(
        chat_id: message.chat.id,
        text: 'Not yet'
    )
  end

  def bye_user
    user = User.first(user_id: @user.id, is_active: true)
    if user
      user.update(is_active: false)
    end
      @bot.api.send_message(
          chat_id: @user.id,
          text: "Bye, #{@user.first_name}. Type /start to start again.")
  end

  def right_format
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Your photo has been accepted. Thank you!'
    )
  end

  def wrong_format
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Your file has a wrong format. Please, send it again'
    )
  end

  def photo_again?
    if Rating.where(user_id: @user.id, date: Date.today).any?
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "We already accepted your photo.")
      true
    else
      false
    end
  end

  def time_out?
    if (Time.now.hour < 9 || Time.now.hour > 21)
      bot.api.send_message(
          chat_id: message.chat.id,
          text: "Time out for task.")
      true
    else
      false
    end
  end
end
require 'net/http'
require 'telegram/bot'
require 'dotenv/load'
require 'sequel'
require 'sqlite3'
require 'rufus-scheduler'
require 'rest-client'
require 'awesome_print'

require_relative 'src/telegram_image_path'
require_relative 'src/sheduller'
require_relative 'src/analyzer'
require_relative 'src/talking'
require_relative 'src/theme'
require_relative 'db/connection'

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

Sheduller.new.call

Telegram::Bot::Client.run(ENV['token']) do |bot|
  bot.listen do |message|
    talking = Talking.new(bot, message)
    if message.photo.any?
    next if talking.user_in?
    next if talking.time_out?
    next if talking.task_is?
    next if talking.photo_again?
      talking.right_format
      Analyzer.new(bot, message.from.id, message.photo.last.file_id, message).result
    elsif message.document
      talking.wrong_format
    else
      case message.text
      when '/start'
        talking.hi_user
      when '/help'
        talking.help
      when '/rules'
        talking.rules
      when '/task'
        talking.task
      when '/ratings'
        talking.ratings_today
      when '/all_ratings'
        talking.all_ratings
      when '/stop'
        talking.bye_user
      else
        talking.help
      end
    end
  end
end
class Sheduller
  attr_accessor :token

  def initialize
    @token = ENV['token']
    end

  def call
    scheduler = Rufus::Scheduler.new
    bot = Telegram::Bot::Client.new(token)
    scheduler.cron '43 20 * * *' do
      Telegram::Bot::Client.run(@token) do |bot|
          Theme.new.send_task
      end
    end
  end
end
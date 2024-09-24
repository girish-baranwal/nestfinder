require 'sidekiq'

class DailyJob

  include Sidekiq::Job

  def perform(*args)
    # Do something later
  end
end

require 'sidekiq/cron/job'

Sidekiq::Cron::Job.create(
  name: 'Property cache refresh every 5 minutes',
  cron: '*/5 * * * *', # This cron syntax schedules it every 5 minutes
  class: 'PropertyCacheRefreshWorker'
)

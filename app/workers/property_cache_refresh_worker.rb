class PropertyCacheRefreshWorker
  include Sidekiq::Worker

  def perform
    recent_properties = Property.where('created_at >= ?', 5.minutes.ago)

    recent_properties.each do |property|
      # Cache refresh logic
      Rails.cache.write("property/#{property.id}/title", property.title)
      Rails.cache.write("property/#{property.id}/city", property.city)
      Rails.cache.write("property/#{property.id}/description", property.description)
      Rails.cache.write("property/#{property.id}/address_line_1", property.address_line_1)
      Rails.cache.write("property/#{property.id}/address_line_2", property.address_line_2)
    end
  end
end

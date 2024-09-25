class PropertiesController < ApplicationController

  # before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def new_contact
    @property = Property.find(params[:id])
    @user_email = current_user.email
  end

  def send_contact
    @property = Property.find(params[:id])
    sender_email = params[:email]
    message = params[:message]

    # Call the mailer to send the email
    PropertyMailer.contact_owner(@property, message, sender_email).deliver_later

    redirect_to @property, notice: 'Your message has been sent to the property owner.'
  end

  def owner_dashboard
    @properties = current_user.properties # Assuming current_user owns properties
  end

  def index
    if params[:query].present? && params[:query].strip != ''
      cache_key = "properties_search_#{params[:query].strip}" # Create a cache key based on the search query

      # loggers
      Rails.logger.debug("Cache Key: #{cache_key}")
      if Rails.cache.exist?(cache_key)
        Rails.logger.debug("Fetching from cache for key: #{cache_key}")
      else
        Rails.logger.debug("Cache miss for key: #{cache_key}")
      end

      @properties = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        properties = Property.search(params[:query], fields: [:description, :title, :city, :postal_code, :address_line_1, :address_line_2])
        Rails.logger.debug("Query executed, properties count: #{properties.count}")
        properties
      end
    else
      cache_key = 'properties_all' # Cache key for all properties without a search query
      @properties = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        Property.all
      end
    end
  end

  def new
    # @property = Property.new
    @property = current_user.properties.build
  end

  def edit
  end


  def show
    cache_key = "property_#{params[:id]}"
    @property = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      Property.find(params[:id])
    end
  end


  def create
    # @property = Property.new(property_params)
    @property = current_user.properties.build(property_params)
    @property.user = current_user  # Assuming you have a `current_user` method for authentication

    if @property.save
      Rails.cache.delete('properties_all') # Invalidate the cache for the index view
      redirect_to properties_path, notice: 'Property posted successfully!'
    else
      puts @property.errors.full_messages  # Log validation errors to the console
      render :new
    end
  end

  def update

    # Handle removing selected images
    if params[:property][:remove_images].present?
      params[:property][:remove_images].each do |image_id|
        image = @property.images.find(image_id)
        image.purge # This deletes the image from ActiveStorage
      end
    end

    # If new images are provided, merge them with existing images
    if params[:property][:images].present?
      @property.images.attach(params[:property][:images])
    end

    if @property.update(property_params.except(:images))
      Rails.cache.delete("property_#{@property.id}") # Invalidate the cache for the updated property
      Rails.cache.delete('properties_all') # Invalidate the index cache
      redirect_to @property
    else
      render 'edit'
    end
  end

  def destroy
    @property.destroy
    Rails.cache.delete("property_#{@property.id}") # Remove the specific property's cache
    Rails.cache.delete('properties_all') # Invalidate the cache for the index view
    redirect_to properties_url, notice: 'Property was successfully destroyed.'
  end

  private

  def property_params
    params.require(:property).permit(:user_id, :price, :description, :status, {images: []}, :latitude, :longitude, :address_line_1, :address_line_2, :city, :postal_code, :title)
  end

  def set_property
    @property = Property.find(params[:id])
  end

  def authorize_owner!
    unless @property.user == current_user
      redirect_to @property, alert: 'You are not authorized to perform this action.'
    end
  end


end

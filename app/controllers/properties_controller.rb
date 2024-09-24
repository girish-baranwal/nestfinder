class PropertiesController < ApplicationController

  before_action :set_property, only: [:show, :edit, :update, :destroy]

  def index
    if params[:query].present? && params[:query].strip != ''
      cache_key = "properties_search_#{params[:query].strip}" # Create a cache key based on the search query
      @properties = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        Property.search(params[:query], fields: [:description, :title, :city, :postal_code, :address_line_1, :address_line_2])
      end
    else
      cache_key = 'properties_all' # Cache key for all properties without a search query
      @properties = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        Property.all
      end
    end
  end

  def new
    @property = Property.new
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
    @property = Property.new(property_params)
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


end

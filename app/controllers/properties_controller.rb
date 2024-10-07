class PropertiesController < ApplicationController

  # before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:owner_dashboard]

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
    @properties = Property.includes(:user, images_attachments: :blob).where(user_id: current_user.id)
  end

  def index
    if params[:query].present? && params[:query].strip != ''
      cache_key = "properties_search_#{params[:query].strip}_user_#{current_user&.id || 'guest'}" # Use 'guest' if no user is logged in

      # Loggers
      Rails.logger.debug("Cache Key: #{cache_key}")
      if Rails.cache.exist?(cache_key)
        Rails.logger.debug("Fetching from cache for key: #{cache_key}")
      else
        Rails.logger.debug("Cache miss for key: #{cache_key}")
      end

      @properties = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        properties = Property.search(params[:query], fields: [:description, :title, :city, :postal_code, :address_line_1, :address_line_2]).includes(:user, images_attachments: :blob)

        # Ensure @properties is an ActiveRecord relation to allow further chaining
        if properties.is_a?(ActiveRecord::Relation)
          properties = properties.where.not(user_id: current_user.id) if current_user
        else
          # Convert the search result to an array and apply filtering
          properties = properties.to_a.reject { |property| property.user_id == current_user.id } if current_user
        end

        Rails.logger.debug("Query executed, properties count: #{properties.count}")
        properties
      end
    else
      cache_key = "properties_all_user_#{current_user&.id || 'guest'}" # Use 'guest' for no user logged in
      @properties = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        properties = Property.includes(:user, images_attachments: :blob).all
        properties = properties.where.not(user_id: current_user.id) if current_user
        properties
      end
    end

    if @properties.is_a?(ActiveRecord::Relation)
      @properties = @properties.order(created_at: :desc)
    else
      @properties = @properties.sort_by(&:created_at).reverse # For array of properties
    end

    # Add pagination after fetching properties
    if @properties.is_a?(Array)
      @properties = Kaminari.paginate_array(@properties).page(params[:page]).per(3)
    else
      @properties = @properties.page(params[:page]).per(3)
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
      Property.includes(
        images_attachments: :blob
      ).find(params[:id])
    end
  end


  def create
    @property = current_user.properties.build(property_params)
    @property.user = current_user

    if @property.save
      Rails.cache.delete("property/#{@property.id}/title")
      Rails.cache.delete("property/#{@property.id}/city")
      Rails.cache.delete("property/#{@property.id}/description")
      Rails.cache.delete("property/#{@property.id}/address_line_1")
      Rails.cache.delete("property/#{@property.id}/address_line_2")
      Rails.cache.delete("properties_search_#{@property.title}_user_guest")
      Rails.cache.delete("properties_search_#{@property.city}_user_guest")
      Rails.cache.delete("properties_search_#{@property.description}_user_guest")
      Rails.cache.delete("properties_search_#{@property.address_line_1}_user_guest")
      Rails.cache.delete("properties_search_#{@property.address_line_2}_user_guest")
      Rails.cache.delete('properties_all')
      redirect_to owner_dashboard_properties_path, notice: 'Property posted successfully!'
    else
      puts @property.errors.full_messages
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
    redirect_to owner_dashboard_properties_path, notice: 'Property was successfully destroyed.'
  end

  def show_agreement
    @property = Property.find(params[:id])

    # Find the current year's agreement for the property
    @current_year_agreement = @property.agreements.find_by("extract(year from start_date) = ?", Date.current.year)
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

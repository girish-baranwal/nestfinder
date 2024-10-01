module Api
  module V1
    class PropertiesController < ApplicationController
      before_action :set_property, only: [:show, :update, :destroy]

      def new_contact
        @property = Property.find(params[:id])
        @user_email = current_user.email

        respond_to do |format|
          format.html
          format.json { render json: { property: PropertyBlueprint.render(@property), user_email: @user_email } }
        end
      end

      def send_contact
        @property = Property.find(params[:id])
        sender_email = params[:email]
        message = params[:message]

        # Call the mailer to send the email
        PropertyMailer.contact_owner(@property, message, sender_email).deliver_later

        respond_to do |format|
          format.html { redirect_to @property, notice: 'Your message has been sent to the property owner.' }
          format.json { render :show, status: :created, location: @property }
        end

        redirect_to @property, notice: 'Your message has been sent to the property owner.'
      end

      def owner_dashboard
        @properties = current_user.properties # Assuming current_user owns properties
        respond_to do |format|
          format.html
          format.json { render json: PropertyBlueprint.render(@properties) }
        end
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

        respond_to do |format|
          format.json { render json: PropertyBlueprint.render(@properties), status: :ok } # JSON response for API
          format.html # regular HTML response
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

        if @property
          respond_to do |format|
            format.json { render json: PropertyBlueprint.render(@property), status: :ok } # JSON response for API
            format.html # regular HTML response
          end
        else
          respond_to do |format|
            format.json { render json: { error: "Property not found" }, status: :not_found } # Error response for API
            format.html { redirect_to properties_path, alert: "Property not found" } # Redirect for HTML
          end
        end
      end

      def create
        # @property = Property.new(property_params)
        @property = current_user.properties.build(property_params)
        @property.user = current_user # Assuming you have a `current_user` method for authentication

        if @property.save
          Rails.cache.delete('properties_all') # Invalidate the cache for the index view
          respond_to do |format|
            format.html { redirect_to properties_path, notice: 'Property posted successfully!' }
            format.json { render json: PropertyBlueprint.render(@property), status: :created } # Return the created property in JSON format
          end
        else
          respond_to do |format|
            format.html { render :new }
            format.json { render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity } # Return validation errors
          end
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
          respond_to do |format|
            format.html { redirect_to @property }
            format.json { render json: PropertyBlueprint.render(@property), status: :ok } # Return the updated property
          end
        else
          respond_to do |format|
            format.html { render 'edit' }
            format.json { render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        @property.destroy
        Rails.cache.delete("property_#{@property.id}") # Remove the specific property's cache
        Rails.cache.delete('properties_all') # Invalidate the cache for the index view
        respond_to do |format|
          format.html { redirect_to properties_url, notice: 'Property was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      private

      def property_params
        params.require(:property).permit(:user_id, :price, :description, :status, { images: [] }, :latitude, :longitude, :address_line_1, :address_line_2, :city, :postal_code, :title)
      end

      def set_property
        @property = Property.find_by(id: params[:id])
        unless @property
          render json: { error: "Property not found" }, status: :not_found
        end
      end


      def authorize_owner!
        unless @property.user == current_user
          redirect_to @property, alert: 'You are not authorized to perform this action.'
        end
      end

    end
  end
end

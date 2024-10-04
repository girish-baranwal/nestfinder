class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :log_cache
  before_action :set_locale
  # rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    # Permit the additional parameters for sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone_number])
    # Permit the additional parameters for account update
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone_number])
  end

  private

  # def record_not_found
  #   render file: "#{Rails.root}/public/404.html", status: :not_found
  # end

  def set_locale
    if current_user
      I18n.locale = current_user.language || I18n.default_locale
    elsif session[:locale]
      I18n.locale = session[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end

  def log_cache
    Rails.cache.instance_variable_set(:@data, ActiveSupport::Cache::MemoryStore.new)
  end

end

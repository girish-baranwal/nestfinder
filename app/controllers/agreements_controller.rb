class AgreementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: [:index, :show, :new, :create, :set_agreement, :sign_owner, :send_to_tenant, :sign_by_tenant, :update_by_tenant ]
  before_action :set_agreement, only: [:show, :edit, :update, :sign_owner, :send_to_tenant, :destroy, :destroy_document, :sign_by_tenant, :update_by_tenant]


  def index
    @agreements = @property.agreements.recent_three_years
  end

  def show
  end
  def new
    @agreement = @property.agreements.build
  end

  def create
    # Rails.logger.debug "Full Params: #{params.inspect}"
    # @agreement = Agreement.new(agreement_params)
    @agreement = @property.agreements.new(agreement_params)
    @agreement.status = 'draft'
    @agreement.owner = current_user
    # @agreement.property = @property
    # @agreement.city = @property.city

    if @agreement.save
      redirect_to property_agreements_path(@property), notice: 'Agreement was successfully saved.'
    else
      flash[:alert] = @agreement.errors.full_messages.join(", ")
      render :new
    end
  end

  def update
    if params[:commit] == 'Send to Tenant'
      @agreement.update(owner_signed_at: Time.current)
      @agreement.update(agreement_params)
      @agreement.send_to_tenant
      # send_to_tenant
      redirect_to property_agreements_path(@property)
    elsif @agreement.update(agreement_params)
      redirect_to property_agreements_path(@property), notice: 'Agreement updated.'
    else
      flash[:alert] = @agreement.errors.full_messages.join(", ")
      render :edit
    end
  end

  # Custom action for tenant to sign the agreement
  def sign_by_tenant
    # Ensure only the tenant can access this action
    unless current_user.email == @agreement.tenant_email
      flash[:alert] = "You are not authorized to sign this agreement."
      redirect_to root_path
    end
  end

  # Action to update the agreement with the tenant's signature
  def update_by_tenant
    if @agreement.update(tenant_signature: params[:agreement][:tenant_signature], tenant_signed_at: Time.current)
      @agreement.update(status: 'completed')
      flash[:notice] = "Agreement signed by the tenant."
      redirect_to property_agreements_path(@property)
    else
      flash[:alert] = "Failed to sign the agreement."
      render :sign_by_tenant
    end
  end

  # Action for owner to sign the agreement
  # def sign_owner
  #   if @agreement.update(owner_signed_at: Time.current)
  #     @agreement.update(status: 'awaiting_tenant_signature')
  #     flash[:notice] = "Agreement signed by the owner."
  #   else
  #     flash[:alert] = "Failed to sign the agreement."
  #   end
  #   redirect_to property_agreements_path(@property)
  # end

  # def send_to_tenant
  #   if @agreement.owner_signed? && @agreement.signature.present?
  #     NotificationMailer.notify_tenant(@agreement).deliver_later
  #     @agreement.update(status: :awaiting_signature)
  #     flash[:notice] = "Agreement sent to tenant for signing."
  #   else
  #     flash[:alert] = "Please complete all required fields before sending."
  #   end
  # end

  def destroy_document
    if current_user == @agreement.owner
      document = @agreement.tenant_identifications.find(params[:id]) || @agreement.owner_documents.find(params[:id])
      document.purge
      redirect_to @agreement, notice: 'Document was successfully deleted.'
    else
      redirect_to @agreement, alert: 'Only the owner can delete documents.'
    end
  end

  private

  def agreement_params
    params.require(:agreement).permit(
      :rent_amount, :maintenance_amount, :deposit_amount,
      :tenant_name, :tenant_email,
      :start_date, :end_date,
      :owner_signature,
      tenant_identifications: [], owner_documents: [],
    )
  end

  def set_property
    Rails.logger.debug "Property ID: #{params[:property_id]}"
    @property = Property.find(params[:property_id])
  end

  def set_agreement
    Rails.logger.debug "Agreement ID: #{params[:id]}"
    @property = Property.find(params[:property_id])
    @agreement = @property.agreements.find(params[:id])
  end

end
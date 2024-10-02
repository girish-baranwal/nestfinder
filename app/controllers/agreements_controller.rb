class AgreementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: [:index, :show, :new, :create]
  before_action :set_agreement, only: [:show, :edit, :update, :destroy, :destroy_document]


  def index
    @agreements = @property.agreements.recent_three_years
  end

  def show

  end
  def new
    @agreement = @property.agreements.build
  end

  def create
    Rails.logger.debug "Full Params: #{params.inspect}"

    # Explicitly permit the whole parameters if needed
    permitted_params = params.permit(:property_id, agreement: [:rent_amount, :maintenance_amount, :deposit_amount, :tenant_name, :tenant_email])

    # Rails.logger.debug "Permitted Params: #{permitted_params.inspect}"

    @agreement = Agreement.new(agreement_params)
    @agreement.property = Property.find(params[:property_id])

    @agreement.owner = current_user
    @agreement.property = @property
    # @agreement.city = @property.city

    if @agreement.save
      redirect_to property_agreements_path(@property), notice: 'Agreement was successfully created.'
    else
      render :new
    end
  end

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
      tenant_identifications: [], owner_documents: []
    )
  end

  def set_property
    Rails.logger.debug "Params: #{params.inspect}"
    @property = Property.find(params[:property_id])
  end

  def set_agreement
    @agreement = @property.agreements.find(params[:id])
  end

end
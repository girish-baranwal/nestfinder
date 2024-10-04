class NotificationMailer < ApplicationMailer
  def notify_tenant(agreement)
    @agreement = agreement
    @tenant_name = agreement.tenant_name
    @sign_url = sign_by_tenant_property_agreement_url(agreement.property, agreement)

    mail(to: agreement.tenant_email, subject: 'Rental Agreement Signature Request')
  end
end

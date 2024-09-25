class PropertyMailer < ApplicationMailer
  default from: 'care@nestfinder.com'

  def contact_owner(property, message, sender_email)
    @property = property
    @message = message
    @sender_email = sender_email
    @owner = @property.user

    mail(to: @owner.email, subject: "Inquiry about your property: #{@property.title}")
  end
end

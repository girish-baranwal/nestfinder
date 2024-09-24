class UserMailer < ApplicationMailer
  default from: 'no-reply@nestfinder.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def password_reset(user)
    @user = user
    @reset_url = edit_user_password_url(user.reset_password_token, email: @user.email)
    mail(to: @user.email, subject: 'Password Reset Instructions')
  end
end

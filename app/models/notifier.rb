class Notifier < ActionMailer::Base

  # Let an admin know there is a new comment that needs validating
  def validate_comment(admin, comment, url)
    setup_email(admin, url)
    @subject += "Comment waiting validation"
    @body[:comment] = comment
  end
  
  # Deliver notification that a new comment has been posted.
  # Requires email as comments don't require users.
  def comment_posted(email, comment, url)
    setup_email
    @recipients = email
    @subject += "New comment"
    @body[:comment] = comment
    @body[:url] = url
  end

  def user_signup(user, url)
    setup_email(user, url)
    @subject += "Confirm Signup" 
  end

  # Let the admin user's know that a new user has been created
  def admin_user_signup(admin, user)
    setup_email(user)
    @recipients = "#{admin.name} <#{admin.email}>"
    @subject += "New user signup"
  end

  protected

  def setup_email(user = nil, url = nil)
    @from = "admin@localhost"
    @recipients = user.full_email if user
    @subject = "JustDocuments: "
    @sent_on = Time.now
    @body[:user] = user if user
    @body[:url] = url if url
    ActionMailer::Base.default_url_options[:host] = 'localhost:3000'
  end

end

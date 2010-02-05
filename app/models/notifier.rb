class Notifier < ActionMailer::Base

  # let the admins know there is a new comment that needs validating
  def validate_comment(user, comment, url)
    setup_email(user, url)
    @subject += "Comment waiting validation"
    @body[:comment] = comment
  end
  
  # Deliver a message to users in the thread and admin that a new
  # message has been posted.
  # Should include the admin user validating the request so that they
  # don't receive the same email twice.
  def comment_posted(user, comment, url)
    setup_email(user, url)
    @subject += "New comment"
    @body[:comment] = comment
  end

  def user_signup(user, url)
    setup_email(user, url)
    @subject .= "Confirm Signup" 
  end

  # Let the admin user's know that a new user has been created
  def admin_user_signup(user)
    setup_email(user)
    @subject += "New user added"
  end

  protected

  def setup_email(user = nil, url = nil)
    @from = "admin@localhost"
    @recipients = "#{user.name} <#{user.email}>" if user
    @subject = "JustDocuments: "
    @sent_on = Time.now
    @body[:user] = user if user
    @body[:url] = url if url
    ActionMailer::Base.default_url_options[:host] = 'localhost:3000'
  end

end

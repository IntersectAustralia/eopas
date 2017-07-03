class ApplicationController < ActionController::Base


  protect_from_forgery

  helper_method :current_user

  def routing_error
   if request.fullpath.end_with? ".png"
     send_file "#{Rails.root}/public/transcodinginProgress.png", type: "image/png", disposition: "inline"
   else
     render "#{Rails.root}/public/404.html", type: "text/html"
   end
  end

  private
  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= current_user_session && current_user_session.user
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def delayed_job_admin_authentication
    permission_denied unless permitted_to? :manage, :app_config
  end

  protected
  def permission_denied
    if current_user
      flash[:error] = "Sorry, you are not allowed to access that page."
      redirect_to root_url
    else
      store_location
      flash[:error] = "You must be logged in to access that page."
      redirect_to login_path
    end
  end


end